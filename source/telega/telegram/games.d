module telega.telegram.games;

import telega.botapi : MessageEntity, PhotoSize, User;

/*** Games types ***/

// TODO add nullable fields
struct Game
{
    string        title;
    string        description;
    PhotoSize[]   photo;
    string        text;
    MessageEntity text_entities;
    Animation     animation;
}

// TODO add nullable fields and a new fields
struct Animation
{
    string    file_id;
    PhotoSize thumb;
    string    file_name;
    string    mime_type;
    uint      file_size;
}

struct CallbackGame
{
    // no fields
}

struct GameHighScore
{
    uint  position;
    User  user;
    uint  score;
}

