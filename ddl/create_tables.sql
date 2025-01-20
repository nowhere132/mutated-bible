CREATE TABLE graces (
    id SERIAL PRIMARY KEY,                   -- ID is the primary key and auto-incremented
    link TEXT NOT NULL,                      -- URL for the web link
    description TEXT,                        -- Description can be nullable
    tags TEXT[],                             -- Array of strings for tags (e.g., #docker, #git)
    created DATE NOT NULL DEFAULT CURRENT_DATE, -- Date when the grace was created
    last_modified DATE NOT NULL DEFAULT CURRENT_DATE, -- Last modified date
    player TEXT NOT NULL                     -- Name of the player/user who collected the grace
);

CREATE TABLE graces_pointers(
    from_grace_id INT,
    to_grace_id INT,
    FOREIGN KEY (from_grace_id) REFERENCES graces(id) ON DELETE CASCADE,
    FOREIGN KEY (to_grace_id) REFERENCES graces(id) ON DELETE CASCADE,
    PRIMARY KEY (from_grace_id, to_grace_id)
);