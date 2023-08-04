class Vars {
  static const KEY_API = "your-youtube-api-token";
  static const DB_NAME_FILE = 'tasks.db';
  static const DB_TASKS_TABLE_NAME = 'tasks';
  static const LINKED_TUBE_VIDEO = 'https://youtu.be/';
  static const PLAYLIST_TUBE_VIDEO = 'https://www.youtube.com/playlist?list=';
  static const YOUTUBE_LINK = 'https://www.youtube.com/';

  static const SCRIPT_TASK = '''CREATE TABLE $DB_TASKS_TABLE_NAME (
    "id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "taskId"	VARCHAR(80) UNIQUE, 
        "idVideo"	VARCHAR(80) NOT NULL , 
        "title"	VARCHAR(80) NOT NULL  , 
        "description"	VARCHAR(80) NOT NULL, 
        "size"	INTEGER NOT NULL,
        "linkDownload"	VARCHAR(80) NOT NULL, 
         "formatFile"	INTEGER NOT NULL,
        "cover"	VARCHAR(80) NOT NULL , 
        "dir_url"	VARCHAR(80) NOT NULL, 
        "date"	VARCHAR(80) NOT NULL,   
        "progress"	INTEGER NOT NULL,
        "stateFile"	INTEGER NOT NULL
    )'''; 
}
