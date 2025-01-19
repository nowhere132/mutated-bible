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


-- graces_link(p_from_id, p_to_id)
-- to create a directed edge (link) between 2 nodes (graces)
CREATE OR REPLACE FUNCTION graces_link(
    p_from_id INT, 
    p_to_id INT
) AS $$
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM graces WHERE graces.id = p_from_id) OR 
       NOT EXISTS (SELECT 1 FROM graces WHERE graces.id = p_to_id) THEN
        RAISE EXCEPTION 'Both IDs must exist in order to link'; 
    END IF; 

    INSERT INTO graces_pointers (from_grace_id, to_grace_id)
    VALUES (p_from_id, p_to_id)
    ON CONFLICT (from_grace_id, to_grace_id) DO UPDATE;
END;
$$ LANGUAGE plpgsql;

-- graces_unlink(p_from_id, p_to_id)
-- to remove a directed edge between 2 nodes
CREATE OR REPLACE FUNCTION graces_unlink(
    p_from_id INT, 
    p_to_id INT
) RETURNS VOID AS $$ 
BEGIN 
    DELETE FROM graces_pointers gp
    WHERE gp.from_grace_id = p_from_id AND gp.to_grace_id = p_to_id;
END;
$$ LANGUAGE plpgsql; 


-- graces_delete(p_id)
-- remove a node (grace) and all related links 
CREATE OR REPLACE FUNCTION graces_delete(
    p_id INT
) RETURNS VOID AS $$
BEGIN 
    DELETE FROM graces WHERE graces.id = p_id; 
END; 
$$ LANGUAGE plpgsql;


-- graces_get_connection(p_id)
-- show all connections (neighbors) of a grace 
-- to construct a knowledge graph, repeat this function for all nodes 
CREATE OR REPLACE FUNCTION graces_get_connections(
    p_id INT
) RETURNS TABLE (
    this JSONB, 
    neighbors JSONB, 
    edges JSONB
) AS $$ 
BEGIN 
    RETURN QUERY 

    WITH 
    -- this node info json 
    this_info AS (
        SELECT jsonb_build_object(
            'id', g.id::TEXT, 
            'data', jsonb_build_object(
                'label', g.link, 
                'description', g.description, 
                'tags', g.tags
            )
        ) as this_info_json 
        FROM graces g 
        WHERE g.id = p_id
    ),

    -- neighbor nodes info json
    neighbors_info AS (
        SELECT DISTINCT 
            g.id, 
            g.link, 
            g.description, 
            g.tags 
        FROM graces g INNER JOIN graces_pointers gp 
        ON (gp.from_grace_id = p_id AND gp.to_grace_id = g.id)
        OR (gp.to_grace_id = p_id AND gp.from_grace_id = p_id)
    ),

    -- edges info json
    edges_info AS (
        SELECT
            gp.from_grace_id, 
            gp.to_grace_id
        FROM graces_pointers gp
        WHERE gp.from_grace_id = p_id OR gp.to_grace_id = p_id
    )

    -- extracting all json format to return
    SELECT
        -- info of this node in reactflow fmt
        (SELECT this_info_json FROM this_info), 

        -- info of neighbor nodes in reactflow fmt
        COALESCE(
            (SELECT jsonb_agg(
                jsonb_build_object(
                    'id', n.id::TEXT, 
                    'data', jsonb_build_object(
                        'label', n.link, 
                        'description', n.description, 
                        'tags', n.tags
                    )
                )
            )
            FROM neighbors_info n),
            '[]'::jsonb
        ), 

        -- info of edges in reactflow fmt 
        COALESCE(
            (SELECT jsonb_agg(
                jsonb_build_object(
                    'id', e.from_grace_id::TEXT || '-' || e.to_grace_id::TEXT, 
                    'source', e.from_grace_id::TEXT, 
                    'target', e.to_grace_id::TEXT
                )
            )
            FROM edges_info e), 
            '[]'::jsonb
        );

END; 
$$ LANGUAGE plpgsql; 
