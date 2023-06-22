<?php
$cveData = json_decode($argv[1],true);
echo('# Composer Audit Report\n=============================\n\n');
foreach ($cveData['advisories'] as $key => $value) {
    echo('- [ ] ['.$value[0]['cve'].']('.$value[0]['link'].') => '.$value[0]['title'].'\n');
}