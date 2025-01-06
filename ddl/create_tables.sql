CREATE TABLE graces (
    id SERIAL PRIMARY KEY,                   -- ID is the primary key and auto-incremented
    link TEXT NOT NULL,                      -- URL for the web link
    description TEXT,                        -- Description can be nullable
    tags TEXT[],                             -- Array of strings for tags (e.g., #docker, #git)
    created DATE NOT NULL DEFAULT CURRENT_DATE, -- Date when the grace was created
    last_modified DATE NOT NULL DEFAULT CURRENT_DATE, -- Last modified date
    player TEXT NOT NULL                     -- Name of the player/user who collected the grace
);