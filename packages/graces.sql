CREATE OR REPLACE FUNCTION graces_collect(
    p_link TEXT,
    p_description TEXT,
    p_tags TEXT[], 
    p_player TEXT
) RETURNS INT AS $$
DECLARE 
    r_id INT; 
BEGIN
    INSERT INTO graces (link, description, tags, created, last_modified, player)
    VALUES (p_link, p_description, p_tags, CURRENT_DATE, CURRENT_DATE, p_player)
    RETURNING graces.id INTO r_id;

    RETURN r_id; 
END; 
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION graces_enhance(
    p_id INT,
    p_description TEXT,
    p_tags TEXT[]
) RETURNS INT AS $$
DECLARE 
    r_id INT; 
BEGIN
    -- Check if description is provided and update it
    IF p_description IS NOT NULL THEN
        UPDATE graces
        SET description = p_description,
            last_modified = CURRENT_DATE
        WHERE id = p_id
        RETURNING graces.id INTO r_id;
    END IF;

    -- Check if tags are provided and update them
    IF p_tags IS NOT NULL THEN
        UPDATE graces
        SET tags = p_tags,
            last_modified = CURRENT_DATE
        WHERE id = p_id
        RETURNING graces.id INTO r_id;
    END IF;

    RETURN r_id; 
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION graces_show(
    p_search TEXT, 
    p_tags TEXT[]
) RETURNS TABLE (
    link TEXT, 
    description TEXT, 
    tags TEXT[], 
    created DATE, 
    last_modified DATE
) AS $$
BEGIN 
    RETURN QUERY 
    SELECT 
        graces.link, 
        graces.description, 
        graces.tags, 
        graces.created, 
        graces.last_modified
    FROM graces 
    WHERE ( p_search IS NULL OR 
            graces.description ILIKE '%' || p_search || '%' OR
            graces.link ILIKE '%' || p_search || '%')
    AND (p_tags IS NULL OR graces.tags && p_tags);
END;
$$ LANGUAGE plpgsql; 
