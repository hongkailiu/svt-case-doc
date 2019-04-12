# Results from Docker Registry Storage Tests

# build and push time

```sh
# grep "Failed builds: " /tmp/build_test.log -A5          
2017-12-04 18:28:34,724 - build_test - MainThread - INFO - Failed builds: 0
2017-12-04 18:28:34,724 - build_test - MainThread - INFO - Invalid builds: 1
2017-12-04 18:28:34,724 - build_test - MainThread - INFO - Good builds included in stats: 499
2017-12-04 18:28:34,724 - build_test - MainThread - INFO - Average build time, all good builds: 122
2017-12-04 18:28:34,724 - build_test - MainThread - INFO - Minimum build time, all good builds: 48
2017-12-04 18:28:34,724 - build_test - MainThread - INFO - Maximum build time, all good builds: 165
--
2017-12-04 18:44:02,373 - build_test - MainThread - INFO - Failed builds: 1
2017-12-04 18:44:02,373 - build_test - MainThread - INFO - Invalid builds: 0
2017-12-04 18:44:02,374 - build_test - MainThread - INFO - Good builds included in stats: 499
2017-12-04 18:44:02,374 - build_test - MainThread - INFO - Average build time, all good builds: 118
2017-12-04 18:44:02,374 - build_test - MainThread - INFO - Minimum build time, all good builds: 47
2017-12-04 18:44:02,374 - build_test - MainThread - INFO - Maximum build time, all good builds: 164
--
2017-12-04 19:06:09,226 - build_test - MainThread - INFO - Failed builds: 0
2017-12-04 19:06:09,226 - build_test - MainThread - INFO - Invalid builds: 0
2017-12-04 19:06:09,226 - build_test - MainThread - INFO - Good builds included in stats: 500
2017-12-04 19:06:09,226 - build_test - MainThread - INFO - Average build time, all good builds: 114
2017-12-04 19:06:09,226 - build_test - MainThread - INFO - Minimum build time, all good builds: 44
2017-12-04 19:06:09,226 - build_test - MainThread - INFO - Maximum build time, all good builds: 165
--
2017-12-04 19:51:10,432 - build_test - MainThread - INFO - Failed builds: 1
2017-12-04 19:51:10,432 - build_test - MainThread - INFO - Invalid builds: 0
2017-12-04 19:51:10,432 - build_test - MainThread - INFO - Good builds included in stats: 999
2017-12-04 19:51:10,433 - build_test - MainThread - INFO - Average build time, all good builds: 205
2017-12-04 19:51:10,433 - build_test - MainThread - INFO - Minimum build time, all good builds: 44
2017-12-04 19:51:10,433 - build_test - MainThread - INFO - Maximum build time, all good builds: 380
--
2017-12-04 20:49:06,765 - build_test - MainThread - INFO - Failed builds: 86
2017-12-04 20:49:06,766 - build_test - MainThread - INFO - Invalid builds: 15
2017-12-04 20:49:06,766 - build_test - MainThread - INFO - Good builds included in stats: 885
2017-12-04 20:49:06,766 - build_test - MainThread - INFO - Average build time, all good builds: 361
2017-12-04 20:49:06,766 - build_test - MainThread - INFO - Minimum build time, all good builds: 46
2017-12-04 20:49:06,766 - build_test - MainThread - INFO - Maximum build time, all good builds: 1123

# grep "Failed builds: " /tmp/build_test.log -A5 
2017-12-05 20:17:48,397 - build_test - MainThread - INFO - Failed builds: 1
2017-12-05 20:17:48,397 - build_test - MainThread - INFO - Invalid builds: 0
2017-12-05 20:17:48,397 - build_test - MainThread - INFO - Good builds included in stats: 499
2017-12-05 20:17:48,397 - build_test - MainThread - INFO - Average build time, all good builds: 128
2017-12-05 20:17:48,397 - build_test - MainThread - INFO - Minimum build time, all good builds: 53
2017-12-05 20:17:48,397 - build_test - MainThread - INFO - Maximum build time, all good builds: 167
--
2017-12-05 20:32:21,834 - build_test - MainThread - INFO - Failed builds: 0
2017-12-05 20:32:21,834 - build_test - MainThread - INFO - Invalid builds: 0
2017-12-05 20:32:21,834 - build_test - MainThread - INFO - Good builds included in stats: 500
2017-12-05 20:32:21,834 - build_test - MainThread - INFO - Average build time, all good builds: 122
2017-12-05 20:32:21,835 - build_test - MainThread - INFO - Minimum build time, all good builds: 47
2017-12-05 20:32:21,835 - build_test - MainThread - INFO - Maximum build time, all good builds: 160
--
2017-12-05 20:41:25,096 - build_test - MainThread - INFO - Failed builds: 1
2017-12-05 20:41:25,096 - build_test - MainThread - INFO - Invalid builds: 0
2017-12-05 20:41:25,096 - build_test - MainThread - INFO - Good builds included in stats: 499
2017-12-05 20:41:25,096 - build_test - MainThread - INFO - Average build time, all good builds: 116
2017-12-05 20:41:25,096 - build_test - MainThread - INFO - Minimum build time, all good builds: 42
2017-12-05 20:41:25,096 - build_test - MainThread - INFO - Maximum build time, all good builds: 176
--
2017-12-05 21:59:55,970 - build_test - MainThread - INFO - Failed builds: 1
2017-12-05 21:59:55,971 - build_test - MainThread - INFO - Invalid builds: 0
2017-12-05 21:59:55,971 - build_test - MainThread - INFO - Good builds included in stats: 999
2017-12-05 21:59:55,971 - build_test - MainThread - INFO - Average build time, all good builds: 204
2017-12-05 21:59:55,971 - build_test - MainThread - INFO - Minimum build time, all good builds: 48
2017-12-05 21:59:55,971 - build_test - MainThread - INFO - Maximum build time, all good builds: 379
--
2017-12-06 01:50:00,195 - build_test - MainThread - INFO - Failed builds: 0
2017-12-06 01:50:00,195 - build_test - MainThread - INFO - Invalid builds: 0
2017-12-06 01:50:00,195 - build_test - MainThread - INFO - Good builds included in stats: 1000
2017-12-06 01:50:00,195 - build_test - MainThread - INFO - Average build time, all good builds: 269
2017-12-06 01:50:00,196 - build_test - MainThread - INFO - Minimum build time, all good builds: 41
2017-12-06 01:50:00,196 - build_test - MainThread - INFO - Maximum build time, all good builds: 442

[fedora@ip-172-31-55-221 ~]$ grep "Failed builds: " /tmp/build_test.log -A5  
2018-04-25 20:56:52,213 - build_test - MainThread - INFO - Failed builds: 0
2018-04-25 20:56:52,213 - build_test - MainThread - INFO - Invalid builds: 0
2018-04-25 20:56:52,213 - build_test - MainThread - INFO - Good builds included in stats: 500
2018-04-25 20:56:52,213 - build_test - MainThread - INFO - Average build time, all good builds: 138
2018-04-25 20:56:52,213 - build_test - MainThread - INFO - Minimum build time, all good builds: 62
2018-04-25 20:56:52,213 - build_test - MainThread - INFO - Maximum build time, all good builds: 177
--
2018-04-25 21:47:28,293 - build_test - MainThread - INFO - Failed builds: 0
2018-04-25 21:47:28,294 - build_test - MainThread - INFO - Invalid builds: 0
2018-04-25 21:47:28,294 - build_test - MainThread - INFO - Good builds included in stats: 500
2018-04-25 21:47:28,294 - build_test - MainThread - INFO - Average build time, all good builds: 141
2018-04-25 21:47:28,294 - build_test - MainThread - INFO - Minimum build time, all good builds: 60
2018-04-25 21:47:28,294 - build_test - MainThread - INFO - Maximum build time, all good builds: 191
--
2018-04-25 22:56:26,000 - build_test - MainThread - INFO - Failed builds: 0
2018-04-25 22:56:26,000 - build_test - MainThread - INFO - Invalid builds: 0
2018-04-25 22:56:26,000 - build_test - MainThread - INFO - Good builds included in stats: 500
2018-04-25 22:56:26,000 - build_test - MainThread - INFO - Average build time, all good builds: 148
2018-04-25 22:56:26,000 - build_test - MainThread - INFO - Minimum build time, all good builds: 71
2018-04-25 22:56:26,001 - build_test - MainThread - INFO - Maximum build time, all good builds: 198
--
2018-04-26 01:39:29,175 - build_test - MainThread - INFO - Failed builds: 0
2018-04-26 01:39:29,175 - build_test - MainThread - INFO - Invalid builds: 0
2018-04-26 01:39:29,175 - build_test - MainThread - INFO - Good builds included in stats: 1000
2018-04-26 01:39:29,176 - build_test - MainThread - INFO - Average build time, all good builds: 333
2018-04-26 01:39:29,176 - build_test - MainThread - INFO - Minimum build time, all good builds: 98
2018-04-26 01:39:29,176 - build_test - MainThread - INFO - Maximum build time, all good builds: 434
--
2018-04-26 02:12:35,563 - build_test - MainThread - INFO - Failed builds: 0
2018-04-26 02:12:35,563 - build_test - MainThread - INFO - Invalid builds: 0
2018-04-26 02:12:35,563 - build_test - MainThread - INFO - Good builds included in stats: 1000
2018-04-26 02:12:35,563 - build_test - MainThread - INFO - Average build time, all good builds: 359
2018-04-26 02:12:35,563 - build_test - MainThread - INFO - Minimum build time, all good builds: 123
2018-04-26 02:12:35,563 - build_test - MainThread - INFO - Maximum build time, all good builds: 479
--
2018-04-26 02:50:25,950 - build_test - MainThread - INFO - Failed builds: 0
2018-04-26 02:50:25,950 - build_test - MainThread - INFO - Invalid builds: 0
2018-04-26 02:50:25,950 - build_test - MainThread - INFO - Good builds included in stats: 1000
2018-04-26 02:50:25,951 - build_test - MainThread - INFO - Average build time, all good builds: 381
2018-04-26 02:50:25,951 - build_test - MainThread - INFO - Minimum build time, all good builds: 126
2018-04-26 02:50:25,951 - build_test - MainThread - INFO - Maximum build time, all good builds: 496

###20180508
$ grep "Failed builds: " /tmp/build_test.log -A5 
2018-05-08 15:32:14,295 - build_test - MainThread - INFO - Failed builds: 0
2018-05-08 15:32:14,295 - build_test - MainThread - INFO - Invalid builds: 0
2018-05-08 15:32:14,295 - build_test - MainThread - INFO - Good builds included in stats: 3000
2018-05-08 15:32:14,295 - build_test - MainThread - INFO - Average build time, all good builds: 355
2018-05-08 15:32:14,295 - build_test - MainThread - INFO - Minimum build time, all good builds: 100
2018-05-08 15:32:14,295 - build_test - MainThread - INFO - Maximum build time, all good builds: 594
--
2018-05-08 16:45:28,775 - build_test - MainThread - INFO - Failed builds: 5
2018-05-08 16:45:28,775 - build_test - MainThread - INFO - Invalid builds: 1
2018-05-08 16:45:28,775 - build_test - MainThread - INFO - Good builds included in stats: 2994
2018-05-08 16:45:28,775 - build_test - MainThread - INFO - Average build time, all good builds: 377
2018-05-08 16:45:28,775 - build_test - MainThread - INFO - Minimum build time, all good builds: 98
2018-05-08 16:45:28,776 - build_test - MainThread - INFO - Maximum build time, all good builds: 503

###20180926
#250 (n=2)
2018-09-26 15:26:18,534 - build_test - MainThread - INFO - Failed builds: 0
2018-09-26 15:26:18,534 - build_test - MainThread - INFO - Invalid builds: 0
2018-09-26 15:26:18,534 - build_test - MainThread - INFO - Good builds included in stats: 500
2018-09-26 15:26:18,534 - build_test - MainThread - INFO - Average build time, all good builds: 119
2018-09-26 15:26:18,534 - build_test - MainThread - INFO - Minimum build time, all good builds: 55
2018-09-26 15:26:18,534 - build_test - MainThread - INFO - Maximum build time, all good builds: 145
2018-09-26 15:26:18,534 - build_test - MainThread - INFO - Average push time, all good builds: 9.308
2018-09-26 15:26:18,534 - build_test - MainThread - INFO - Minimum push time, all good builds: 3.0
2018-09-26 15:26:18,535 - build_test - MainThread - INFO - Maximum push time, all good builds: 33.0
#250 (n=2)
2018-09-26 15:35:23,632 - build_test - MainThread - INFO - Failed builds: 0
2018-09-26 15:35:23,632 - build_test - MainThread - INFO - Invalid builds: 0
2018-09-26 15:35:23,632 - build_test - MainThread - INFO - Good builds included in stats: 500
2018-09-26 15:35:23,632 - build_test - MainThread - INFO - Average build time, all good builds: 123
2018-09-26 15:35:23,632 - build_test - MainThread - INFO - Minimum build time, all good builds: 65
2018-09-26 15:35:23,632 - build_test - MainThread - INFO - Maximum build time, all good builds: 150
2018-09-26 15:35:23,632 - build_test - MainThread - INFO - Average push time, all good builds: 9.622
2018-09-26 15:35:23,632 - build_test - MainThread - INFO - Minimum push time, all good builds: 3.0
2018-09-26 15:35:23,632 - build_test - MainThread - INFO - Maximum push time, all good builds: 40.0

#500 (n=6)
2018-09-26 16:25:15,514 - build_test - MainThread - INFO - Failed builds: 0
2018-09-26 16:25:15,514 - build_test - MainThread - INFO - Invalid builds: 0
2018-09-26 16:25:15,514 - build_test - MainThread - INFO - Good builds included in stats: 3000
2018-09-26 16:25:15,514 - build_test - MainThread - INFO - Average build time, all good builds: 240
2018-09-26 16:25:15,514 - build_test - MainThread - INFO - Minimum build time, all good builds: 70
2018-09-26 16:25:15,514 - build_test - MainThread - INFO - Maximum build time, all good builds: 332
2018-09-26 16:25:15,514 - build_test - MainThread - INFO - Average push time, all good builds: 30.2643333333
2018-09-26 16:25:15,514 - build_test - MainThread - INFO - Minimum push time, all good builds: 1.0
2018-09-26 16:25:15,514 - build_test - MainThread - INFO - Maximum push time, all good builds: 147.0

#750 (n=2)
2018-09-26 17:01:08,710 - build_test - MainThread - INFO - Failed builds: 0
2018-09-26 17:01:08,710 - build_test - MainThread - INFO - Invalid builds: 0
2018-09-26 17:01:08,710 - build_test - MainThread - INFO - Good builds included in stats: 1500
2018-09-26 17:01:08,710 - build_test - MainThread - INFO - Average build time, all good builds: 363
2018-09-26 17:01:08,710 - build_test - MainThread - INFO - Minimum build time, all good builds: 91
2018-09-26 17:01:08,710 - build_test - MainThread - INFO - Maximum build time, all good builds: 531
2018-09-26 17:01:08,710 - build_test - MainThread - INFO - Average push time, all good builds: 48.046
2018-09-26 17:01:08,710 - build_test - MainThread - INFO - Minimum push time, all good builds: 8.0
2018-09-26 17:01:08,710 - build_test - MainThread - INFO - Maximum push time, all good builds: 216.0

#750 (n=2)
2018-09-26 17:34:48,620 - build_test - MainThread - INFO - Failed builds: 39
2018-09-26 17:34:48,620 - build_test - MainThread - INFO - Invalid builds: 0
2018-09-26 17:34:48,620 - build_test - MainThread - INFO - Good builds included in stats: 1461
2018-09-26 17:34:48,620 - build_test - MainThread - INFO - Average build time, all good builds: 390
2018-09-26 17:34:48,620 - build_test - MainThread - INFO - Minimum build time, all good builds: 61
2018-09-26 17:34:48,620 - build_test - MainThread - INFO - Maximum build time, all good builds: 554
2018-09-26 17:34:48,620 - build_test - MainThread - INFO - Average push time, all good builds: 57.7227926078
2018-09-26 17:34:48,620 - build_test - MainThread - INFO - Minimum push time, all good builds: 5.0
2018-09-26 17:34:48,620 - build_test - MainThread - INFO - Maximum push time, all good builds: 317.0

### 20190411
#250 (n=2)
$ grep -i "Failed builds" /tmp/build_test.log -A 8
2019-04-11 15:41:56,745 - build_test - MainThread - INFO - Failed builds: 0
2019-04-11 15:41:56,745 - build_test - MainThread - INFO - Invalid builds: 0
2019-04-11 15:41:56,745 - build_test - MainThread - INFO - Good builds included in stats: 500
2019-04-11 15:41:56,745 - build_test - MainThread - INFO - Average build time, all good builds: 413
2019-04-11 15:41:56,746 - build_test - MainThread - INFO - Minimum build time, all good builds: 142
2019-04-11 15:41:56,746 - build_test - MainThread - INFO - Maximum build time, all good builds: 556
2019-04-11 15:41:56,746 - build_test - MainThread - INFO - Average push time, all good builds: 3.538
2019-04-11 15:41:56,746 - build_test - MainThread - INFO - Minimum push time, all good builds: 1.0
2019-04-11 15:41:56,746 - build_test - MainThread - INFO - Maximum push time, all good builds: 14.0
--
2019-04-11 16:15:33,040 - build_test - MainThread - INFO - Failed builds: 0
2019-04-11 16:15:33,040 - build_test - MainThread - INFO - Invalid builds: 0
2019-04-11 16:15:33,040 - build_test - MainThread - INFO - Good builds included in stats: 500
2019-04-11 16:15:33,040 - build_test - MainThread - INFO - Average build time, all good builds: 422
2019-04-11 16:15:33,040 - build_test - MainThread - INFO - Minimum build time, all good builds: 96
2019-04-11 16:15:33,040 - build_test - MainThread - INFO - Maximum build time, all good builds: 538
2019-04-11 16:15:33,040 - build_test - MainThread - INFO - Average push time, all good builds: 3.438
2019-04-11 16:15:33,040 - build_test - MainThread - INFO - Minimum push time, all good builds: 1.0
2019-04-11 16:15:33,040 - build_test - MainThread - INFO - Maximum push time, all good builds: 10.0

#500 (n=2)
2019-04-11 17:37:15,853 - build_test - MainThread - INFO - Failed builds: 273
2019-04-11 17:37:15,853 - build_test - MainThread - INFO - Invalid builds: 0
2019-04-11 17:37:15,853 - build_test - MainThread - INFO - Good builds included in stats: 727
2019-04-11 17:37:15,853 - build_test - MainThread - INFO - Average build time, all good builds: 1184
2019-04-11 17:37:15,853 - build_test - MainThread - INFO - Minimum build time, all good builds: 286
2019-04-11 17:37:15,854 - build_test - MainThread - INFO - Maximum build time, all good builds: 1591
2019-04-11 17:37:15,854 - build_test - MainThread - INFO - Average push time, all good builds: 17.8431911967
2019-04-11 17:37:15,854 - build_test - MainThread - INFO - Minimum push time, all good builds: 1.0
2019-04-11 17:37:15,854 - build_test - MainThread - INFO - Maximum push time, all good builds: 90.0
--
2019-04-11 18:48:39,707 - build_test - MainThread - INFO - Failed builds: 53
2019-04-11 18:48:39,707 - build_test - MainThread - INFO - Invalid builds: 0
2019-04-11 18:48:39,707 - build_test - MainThread - INFO - Good builds included in stats: 947
2019-04-11 18:48:39,707 - build_test - MainThread - INFO - Average build time, all good builds: 1302
2019-04-11 18:48:39,707 - build_test - MainThread - INFO - Minimum build time, all good builds: 336
2019-04-11 18:48:39,707 - build_test - MainThread - INFO - Maximum build time, all good builds: 1969
2019-04-11 18:48:39,708 - build_test - MainThread - INFO - Average push time, all good builds: 13.3146779303
2019-04-11 18:48:39,708 - build_test - MainThread - INFO - Minimum push time, all good builds: 2.0
2019-04-11 18:48:39,708 - build_test - MainThread - INFO - Maximum push time, all good builds: 61.0

### observations
image-registry-7886498b66-zsqsh got recreated during the test
### node-ca-8f8xt restarted
node-ca-8f8xt                                      1/1       Running   1          
### abnormal builds
svt-nodejs-147     nodejs-mongodb-example-6   Source   Git@e59fe75   Failed (PushImageToRegistryFailed)   About an hour ago    21m34s
svt-nodejs-137     nodejs-mongodb-example-6   Source   Git@e59fe75   Failed (OutOfMemoryKilled)           About an hour ago    21m44s
svt-nodejs-30      nodejs-mongodb-example-7   Source   Git@e59fe75   Failed (GenericBuildFailed)          39 minutes ago      17m5s
svt-nodejs-a-196   nodejs-mongodb-example-3   Source   Git@e59fe75   Error (BuildPodDeleted)              About an hour ago   33m54s
### prometheus-adapter pod get recreated as well
prometheus-adapter-6fcd6467d6-phkj4            0/1     ContainerCreating   0          8s
### image-registry pod (and prometheus-k8s pods) also runs on worker node, competing resources with build pods.

#500 (n=2) s3
2019-04-11 20:09:59,640 - build_test - MainThread - INFO - Failed builds: 2
2019-04-11 20:09:59,640 - build_test - MainThread - INFO - Invalid builds: 0
2019-04-11 20:09:59,640 - build_test - MainThread - INFO - Good builds included in stats: 998
2019-04-11 20:09:59,640 - build_test - MainThread - INFO - Average build time, all good builds: 1386
2019-04-11 20:09:59,640 - build_test - MainThread - INFO - Minimum build time, all good builds: 299
2019-04-11 20:09:59,640 - build_test - MainThread - INFO - Maximum build time, all good builds: 1850
2019-04-11 20:09:59,640 - build_test - MainThread - INFO - Average push time, all good builds: 13.8296593186
2019-04-11 20:09:59,640 - build_test - MainThread - INFO - Minimum push time, all good builds: 2.0
2019-04-11 20:09:59,640 - build_test - MainThread - INFO - Maximum push time, all good builds: 94.0
#500 (n=6) s3
2019-04-11 23:45:43,820 - build_test - MainThread - INFO - Failed builds: 106                                  
2019-04-11 23:45:43,820 - build_test - MainThread - INFO - Invalid builds: 2                                   
2019-04-11 23:45:43,820 - build_test - MainThread - INFO - Good builds included in stats: 2892                 
2019-04-11 23:45:43,820 - build_test - MainThread - INFO - Average build time, all good builds: 1508           
2019-04-11 23:45:43,820 - build_test - MainThread - INFO - Minimum build time, all good builds: 182            
2019-04-11 23:45:43,820 - build_test - MainThread - INFO - Maximum build time, all good builds: 2168           
2019-04-11 23:45:43,820 - build_test - MainThread - INFO - Average push time, all good builds: 13.3813969571   
2019-04-11 23:45:43,820 - build_test - MainThread - INFO - Minimum push time, all good builds: 3.0             
2019-04-11 23:45:43,820 - build_test - MainThread - INFO - Maximum push time, all good builds: 82.0

```
