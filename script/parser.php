<?php

	if($argv[1]){
        $db  = new PDO('sqlite:results.db') or die("cannot open the database");
		//CREATE TABLE results (id INTEGER PRIMARY KEY AUTOINCREMENT, bw text, delay text, method text, site text, onContentLoad INTEGER, onLoad INTEGER)
		//$db->query('DELETE FROM results');
		//$db->query("UPDATE sqlite_sequence SET seq = 0 WHERE name = 'results'");
		$dir = opendir($argv[1]);
	    while($file = readdir($dir)){
	    	if($file != "." && $$file != ".."){
	    		if(strpos($file,'.har') !== false){
	    			list($bw,$delay,$method,$site) = explode('-',$file);
	    			$str_data = file_get_contents($argv[1].$file);
					$data = json_decode($str_data,true);
					$onContentLoad = $data['log']['pages'][0]['pageTimings']['onContentLoad'];
					$onLoad = $data['log']['pages'][0]['pageTimings']['onLoad'];
					$sql = "INSERT INTO results(bw,delay,method,site,onContentLoad,onLoad) VALUES ('$bw','$delay','$method','$site',$onContentLoad,$onLoad)";
					$db->query($sql);
	    		}
	    	}
	    }
    }else{
    	echo "Usage: php parser.php directory_with_hars";
    }

?>