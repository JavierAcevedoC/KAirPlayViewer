import QtQuick 2.15
import QtQuick.Controls 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQuick.Layouts 1.1
import QtQuick.LocalStorage 2.0

ColumnLayout {
    id: page
    width: 320
    height:320
    Layout.alignment: Qt.AlignHCenter

    signal asyncTaskCompleted(var result)

    WorkerScript {
        id: worker

        source: "WorkerJson.mjs"

        onMessage: (messageData) => {
                if (messageData.task === "asyncTask") {
                    asyncTaskCompleted(messageData.data);
                }
        }
    }

    function insertFromJson(jsonContent) {
        var db = LocalStorage.openDatabaseSync("KAirplayViewer", "1.0", "My Database for airplay list", 100000);
        db.transaction(function(tx) {
            var splited = jsonContent.split(",");

            var fieldName = "";
            var valueField = "";

            for (var key in splited) {

                if (key % 2 == 0 ) {
                    fieldName = cleanText(splited[key]);
                } else {
                    valueField = cleanText(splited[key]);
                    tx.executeSql('INSERT OR REPLACE INTO jsonData VALUES(?, ?)', [fieldName, valueField]);
                }
            }
        });
    }

    function cleanText(text) {
        return ""+text.match(/\b\w+\b/g);
    }

    function startAsyncTask() {
        worker.sendMessage({ task: "asyncTask", data: "someData" });
    }

    function initDB() {
        var db = LocalStorage.openDatabaseSync("KAirplayViewer", "1.0", "My Database for airplay list", 100000);
        if (db) {
            db.transaction(function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS jsonData(key TEXT UNIQUE, value TEXT)');
            });
        }
    }

    function readDataDB(result){
        var db = LocalStorage.openDatabaseSync("KAirplayViewer", "1.0", "My Database for airplay list", 100000);
        console.log('Reading data from DB')
        if (db) {
            db.transaction(function(tx) {
                var rs = tx.executeSql('SELECT * FROM jsonData');
                var r = ""
                for (var i = 0; i < rs.rows.length; i++) {
                    r += rs.rows.item(i).key + ": " + rs.rows.item(i).value + "\n";
                    console.log(r);
                }
                resultText = r;
            });
        }
    }

    Button {
        icon.name: "state-sync"
        text: "Sync Metadata"
        onClicked: startAsyncTask()
        Layout.alignment: Qt.AlignHCenter
    }

    onAsyncTaskCompleted: {
        insertFromJson(result);
        readDataDB(result);
    }

    property string resultText: ""

    Text {
            id: kairtext
            text: {
                text = "KAirplayViewer"
            }
            font.pointSize: 20;
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: resultText
    }

}
