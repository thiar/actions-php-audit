<?php
$cveData = json_decode($argv[1],true);
echo('# NPM Audit Report\n=============================\n\n');
foreach ($cveData['vulnerabilities'] as $key => $value) {
    if(is_array($value['via'][0])){
        echo('- [ ] ['.$value['via'][0]['name'].']('.$value['via'][0]['url'].') => '.$value['via'][0]['title'].'\n'); 
    }
}