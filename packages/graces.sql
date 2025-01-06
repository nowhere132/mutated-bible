CREATE OR REPLACE FUNCTION graces_collect(
    p_link TEXT,
    p_description TEXT,
    p_tags TEXT[], 
    p_player TEXT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO graces (link, description, tags, created, last_modified, player)
    VALUES (p_link, p_description, p_tags, CURRENT_DATE, CURRENT_DATE, p_player);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION graces_enhance(
    p_id INT,
    p_description TEXT,
    p_tags TEXT[]
) RETURNS VOID AS $$
BEGIN
    -- Check if description is provided and update it
    IF p_description IS NOT NULL THEN
        UPDATE graces
        SET description = p_description,
            last_modified = CURRENT_DATE
        WHERE id = p_id;
    END IF;

    -- Check if tags are provided and update them
    IF p_tags IS NOT NULL THEN
        UPDATE graces
        SET tags = p_tags,
            last_modified = CURRENT_DATE
        WHERE id = p_id;
    END IF;
END;
$$ LANGUAGE plpgsql;