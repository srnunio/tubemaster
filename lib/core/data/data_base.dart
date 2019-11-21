import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:tubemaster/core/model/download_data.dart';
import 'package:tubemaster/utils/Utils.dart';
import 'package:tubemaster/utils/constants.dart';

class DataBaseUtils {
  static Database database;
  bool update = false;

  static initDB() async {
    final dbFolder = await getDatabasesPath();
    if (!await Directory(dbFolder).exists()) {
      await Directory(dbFolder).create(recursive: true);
    }
    final dbPath = join(dbFolder, Vars.DB_NAME_FILE);
    database = await openDatabase(dbPath, version: 4,
        onCreate: (Database db, int version) async {
      await db.execute(Vars.SCRIPT_TASK);
    });
  }

//  Future<List<Content>> contentsAllAnotation(int id) async {
//    List<Content> contents = [];
//    try {
//      String query =
//          'select * from $DB_ANOTATION_TABLE_CONTENT where id_anotation = ${id} order by id desc';
////      print('contentsAllAnotation|query : ${query}');
//      List<Map> jsons = await this.database.rawQuery(query);
//      contents = jsons.map((json) => Content.fromJsonMap(json)).toList();
//    } catch (ex) {
//      print('contentsAllAnotation => ${ex.toString()}');
//    }
//    return contents != null ? contents : List<Content>();
//  }

  static Future<int> deleteTask({int id}) async {
    int result = -1;
    await database.transaction((Transaction t) async {
      result = await t.rawDelete(
          '''delete  from ${Vars.DB_TASKS_TABLE_NAME} where id = ${id}''');
    });
    print('update: ${result}');
    return result;
  }

  static Future<bool> existAnnotationDb(String title) async {
    var query =
        'select * from $Vars.DB_TASKS_TABLE_NAME where title = ${"'${title}'"}';
    List<Map> jsons = await database.rawQuery(query);
    return jsons != null && jsons.length > 0 ? true : false;
  }

  static Future<TaskDownloader> getTask(String taskId) async {
    try {
      List<Map> maps = await database.query(Vars.DB_TASKS_TABLE_NAME,
          where: 'taskId = ?',
          whereArgs: ['taskId']);
      if (maps.length > 0) {
        var downloader = TaskDownloader();
        downloader.id = maps.first['id'];
        downloader.taskId = maps.first['taskId'];
        downloader.idVideo = maps.first['idVideo'];
        downloader.title = maps.first['title'];
        downloader.description = maps.first['description'];
        downloader.linkDownload = maps.first['linkDownload'];
        downloader.formatFile = maps.first['formatFile'];
        downloader.cover = maps.first['cover'];
        downloader.dir_url = maps.first['dir_url'];
        downloader.date = maps.first['date'];
        downloader.progress = maps.first['progress'];
        downloader.size = maps.first['size'];
        downloader.stateFile = maps.first['stateFile'];
        return downloader;
//      return TaskDownloader.fromJsonMap(maps.first);
      }
    }catch(ex){
      Utils.logs('getTask Excpetion ${ex.toString()}');
    }
    return null;
  }


  static Future<int> insertOrUpadateDb(TaskDownloader downloader,
      {String column = ''}) async {
    int result = -1;
    Utils.logs('insertOrUpadateDb :  downloader = ${downloader.toJson()}'); 
    try {
      if (downloader.id > 0) {
        result = await updateTaskDb(downloader, column: column);
      } else {
        result = await insertAnotationDb(downloader);
      }
    } catch (ex) {
      Utils.logs('insertOrUpadate:Error ${ex.toString()}');
      result = -1;
    }
    return result;
  }

//  Future<int> countItemsAnottaionDb({int id}) async {
//    if (database == null) {
//      await initDB();
//    }
//    var jsons = await this.database.rawQuery(
//        'select count(*) as numItems from $DB_ANOTATION_TABLE_CONTENT where id_anotation = ${id} order by id desc');
//    return jsons.map((json) => json['numItems']).toList()[0];
//  }

  static Future<int> insertAnotationDb(TaskDownloader downloader) async {
    int result = -1;
    var query =  '''insert into ${Vars.DB_TASKS_TABLE_NAME} (taskId,idVideo,title,description,size,linkDownload,formatFile,cover,dir_url,date,progress,stateFile) values (
              "${downloader.taskId}",
              "${downloader.idVideo}",
              "${Utils.text(downloader.title)}",
              "${Utils.text(downloader.description)}",
              "${downloader.size}",
              "${downloader.linkDownload}",
              "${downloader.formatFile}",
              "${downloader.cover}",
              "${downloader.dir_url}",
              "${downloader.date}",
              "${downloader.progress}",
              "${downloader.stateFile}"
              )
          ''';
    await database.transaction((Transaction t) async {
      result = await t.rawInsert(query);
    });
 
    Utils.logs('query: ${query}');
    Utils.logs('insert: ${result}');
    return result;
  }



  static Future<int> updateTaskDb(TaskDownloader downloader,
      {String column = ''}) async {
    int result = -1;

    var query = '';
    if (column.contains(DownloaderColmn.taskId)) {
      query = downloader.taskId;
    } else if (column.contains(DownloaderColmn.progress)) {
      query = '${downloader.progress}';
    } else if (column.contains(DownloaderColmn.stateFile)) {
      query = '${downloader.stateFile}';
    }
    column = column.length > 0 ? '${column} = ?' : '';
    
    if(column.isEmpty){
      Utils.logs('Especifica a table a alterar ${column}');
      return result;
    }

    await database.transaction((Transaction t) async {
      result = await t.rawUpdate(
          'UPDATE ${Vars.DB_TASKS_TABLE_NAME} SET ${column}  WHERE id = ?',
          ['${query}', '${downloader.id}']);
    });
    Utils.logs('query = : ${query}');
    Utils.logs('updateAnotation: ${result}');
    return result;
  }


  static Future<int> updateAllTast(TaskDownloader downloader) async {
    return await database.update(Vars.DB_TASKS_TABLE_NAME, downloader.toJson(),
        where: 'id = ?', whereArgs: [downloader.id]);
  }

}
