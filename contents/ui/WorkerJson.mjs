WorkerScript.onMessage = function(data) {
    console.log(data.task);

    function loadJSONData() {
        var outData = []
        var file = new XMLHttpRequest();
        file.open("GET", "example.json", true);
        file.onreadystatechange = function() {
            if (file.readyState === XMLHttpRequest.DONE) {
                if (file.status === 200) {
                    var jsonContent = JSON.parse(file.responseText);
                    for (var key in jsonContent) {
                        outData.push(key, jsonContent[key]);
                        console.log(key + ": "+ JSON.stringify(jsonContent[key]));
                    }
                }
                WorkerScript.sendMessage({ task: "asyncTask", data: JSON.stringify(outData)});
            }
        }
        file.send();
    }

    loadJSONData();
}
