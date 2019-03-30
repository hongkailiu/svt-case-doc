# pprof

* [net/http/pprof](https://golang.org/pkg/net/http/pprof/) and [runtime/pprof](https://golang.org/pkg/runtime/pprof/)
* blogs: [1](https://jvns.ca/blog/2017/09/24/profiling-go-with-pprof/), [2](https://blog.golang.org/profiling-go-programs), and [3](https://coder.today/tech/2018-11-10_profiling-your-golang-app-in-3-steps/)

## install required tools

```
$ sudo dnf install graphviz
```

## test-go

[gin-contrib/pprof](https://github.com/gin-contrib/pprof)

`pprof` provides web interface to expose profiles: `http://localhost:8080/debug/pprof/`.

Those data can be processed by `go tool pprof` or `go tool trace`:

```
$ go tool pprof  http://localhost:8080/debug/pprof/heap
Fetching profile over HTTP from http://localhost:8080/debug/pprof/heap
Saved profile in /home/hongkliu/pprof/pprof.testctl.alloc_objects.alloc_space.inuse_objects.inuse_space.003.pb.gz
File: testctl
Type: inuse_space
Time: Mar 30, 2019 at 5:50pm (EDT)
Entering interactive mode (type "help" for commands, "o" for options)
(pprof) top
Showing nodes accounting for 3098.85kB, 100% of 3098.85kB total
Showing top 10 nodes out of 47
      flat  flat%   sum%        cum   cum%
 1048.69kB 33.84% 33.84%  1048.69kB 33.84%  regexp/syntax.(*compiler).inst
  513.50kB 16.57% 50.41%   513.50kB 16.57%  regexp.onePassCopy
  512.28kB 16.53% 66.94%   512.28kB 16.53%  github.com/hongkailiu/test-go/vendor/github.com/go-openapi/spec.(*SchemaOrArray).UnmarshalJSON
  512.28kB 16.53% 83.47%   512.28kB 16.53%  reflect.mapassign
  512.10kB 16.53%   100%   512.10kB 16.53%  encoding/gob.buildTypeInfo
         0     0%   100%   512.10kB 16.53%  encoding/gob.getTypeInfo
         0     0%   100%   512.10kB 16.53%  encoding/gob.init
         0     0%   100%   512.10kB 16.53%  encoding/gob.init.1
         0     0%   100%   512.10kB 16.53%  encoding/gob.mustGetTypeInfo
         0     0%   100%  1024.56kB 33.06%  encoding/json.(*decodeState).object

$ go tool pprof -top  http://localhost:8080/debug/pprof/heap
$ go tool pprof -png  http://localhost:8080/debug/pprof/heap > out.png

### offline profiling
$ go tool pprof ~/pprof/pprof.testctl.alloc_objects.alloc_space.inuse_objects.inuse_space.002.pb.gz

```

