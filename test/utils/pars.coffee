
Test('parsing', 'parsing').run ($test, alight) ->
    pars = (line, expected, cfg) ->
        $test.start 1
        pe = alight.utils.parsExpression line, cfg

        if pe.result isnt expected[0]
            $test.error pe.result
            return
        else
            if pe.filters or expected.length > 1
                # filters
                if not pe.filters
                    $test.error pe.filters
                    return
                if pe.filters.length isnt expected.length-1
                    $test.error pe.filters
                    return
                for filter, i in pe.filters
                    if filter isnt expected[i+1]
                        $test.error pe.filters
                        return
        $test.ok expected

    # ($$=$$scope.a,$$==null)?undefined:($$=$$.b,$$==null)?undefined:$$.c
    pars 'path.variable', ["(($$=$$scope.path,$$==null)?undefined:$$.variable)"]
    pars 'aaa.bbb.ccc.fn()', ["(($$=$$scope.aaa,$$==null)?undefined:($$=$$.bbb,$$==null)?undefined:$$.ccc).fn()"]
    pars 'aaa.bbb.fn()', ["(($$=$$scope.aaa,$$==null)?undefined:$$.bbb).fn()"]
    pars 'aaa.fn()', ["$$scope.aaa.fn()"]
    pars 'fn()', ["$$scope.fn()"]
    pars 'variable', ["$$scope.variable"]
    pars 'a + b.c + d.e.f', ["$$scope.a + (($$=$$scope.b,$$==null)?undefined:$$.c) + (($$=$$scope.d,$$==null)?undefined:($$=$$.e,$$==null)?undefined:$$.f)"]
    pars 'foo.baz=one.two.three', ["$$scope.foo.baz=(($$=$$scope.one,$$==null)?undefined:($$=$$.two,$$==null)?undefined:$$.three)"]
    pars 'foo.baz==one.two.three', ["(($$=$$scope.foo,$$==null)?undefined:$$.baz)==(($$=$$scope.one,$$==null)?undefined:($$=$$.two,$$==null)?undefined:$$.three)"]
    pars 'a=5; b=6;', ["($$scope.$root || $$scope).a=5; ($$scope.$root || $$scope).b=6;"]
    pars 'do(item)', ["$$scope.do($$scope.item)"]
    pars "a+'/'+b", ["$$scope.a+'/'+$$scope.b"]
    pars 'page==5', ["$$scope.page==5"]
    pars 'page<=5', ["$$scope.page<=5"]
    pars 'page>=5', ["$$scope.page>=5"]
    #pars "path.var | toref | filter 'ref|str' ", ["(($$=$$scope.path,$$==null)?undefined:$$.var) ", " toref ", " filter 'ref|str' "]
    #pars " (function(){ return '|' })() | toref | filter", [" (function(){ return '|' })() ", " toref ", " filter"]
    pars " (a || b) ", [" ($$scope.a || $$scope.b) "]
    pars " (a | b) | filter ", [" ($$scope.a | $$scope.b) ", " filter "]
    pars " { red:true, blue:false }[color] ", [" { red:true, blue:false }[$$scope.color] "]
    #pars "x + function(){ return num + 5 }()", ['$$scope.x + function(){ return $$scope.num + 5 }()']
    pars "this.title='linux'; click()", ["$$scope.title='linux'; $$scope.click()"]
    pars "[1,2,3,4,5,6,7,8,9]", ["[1,2,3,4,5,6,7,8,9]"]
    pars "$index===0", ["$$scope.$index===0"]
    pars "list[key].value", ['(($$=$$scope.list,$$==null)?undefined:($$=$$[$$scope.key],$$==null)?undefined:$$.value)']
    pars "list[key].value = test", ['$$scope.list[$$scope.key].value = test'], { input:['test'] }
    pars 'obj.ext.visible', ['(($$=$$scope.obj,$$==null)?undefined:($$=$$.ext,$$==null)?undefined:$$.visible)']
    pars 'a || b | filter', ['$$scope.a || $$scope.b ', ' filter']
    pars "value = $event.keyCode", ['($$scope.$root || $$scope).value = $event.keyCode'], { input:['$event'] }
    pars "'('+a+')'", ["'('+$$scope.a+')'"]
    pars "{ key:value, key2:value2 }", ["{ key:$$scope.value, key2:$$scope.value2 }"]
    pars 'a.b.c.d.e.f.g', ["(($$=$$scope.a,$$==null)?undefined:($$=$$.b,$$==null)?undefined:($$=$$.c,$$==null)?undefined:($$=$$.d,$$==null)?undefined:($$=$$.e,$$==null)?undefined:($$=$$.f,$$==null)?undefined:$$.g)"]
    pars "scope=this", ["($$scope.$root || $$scope).scope=$$scope"]
    pars "info.user.acl('write', 're_type:546a1d07bb05aa73a632807d')", ["(($$=$$scope.info,$$==null)?undefined:$$.user).acl('write', 're_type:546a1d07bb05aa73a632807d')"]
    cyWord = "\u041f\u0440\u043e\u0432\u0435\u0440\u043a\u0430\u041a\u0438\u0440\u0438\u043b\u0438\u0446\u044b\u0401\u0451\u0419\u0439"
    pars "Form.#{cyWord}", ["(($$=$$scope.Form,$$==null)?undefined:$$.#{cyWord})"]
    pars 'a++', ["($$scope.$root || $$scope).a++"]
    pars 'a.b--', ["$$scope.a.b--"]
    pars 'a.b.c+=5', ["$$scope.a.b.c+=5"]
    pars 'a=1', ["($$scope.$root || $$scope).a=1"]
    pars 'a.b=1', ["$$scope.a.b=1"]
    pars 'a.b.c=1', ["$$scope.a.b.c=1"]
    pars 'data[$index]', ['(($$=$$scope.data,$$==null)?undefined:$$[$$scope.$index])']
    pars 'path.data[$index]', ['(($$=$$scope.path,$$==null)?undefined:($$=$$.data,$$==null)?undefined:$$[$$scope.$index])']
    pars 'data[$index]=$value', ['$$scope.data[$$scope.$index]=$value'], { input:['$value'] }
    pars 'path.data[$index]=$value', ['$$scope.path.data[$$scope.$index]=$value'], { input:['$value'] }
    pars 'data[$index]++', ['$$scope.data[$$scope.$index]++']
    pars 'test = "string\\"x"', ['($$scope.$root || $$scope).test = "string\\"x"']
    pars 'data.user[some.data[kk] + someKey].key[kk] + "xx\\"x" + suffix', ['(($$=$$scope.data,$$==null)?undefined:($$=$$.user,$$==null)?undefined:($$=$$[(($$=$$scope.some,$$==null)?undefined:($$=$$.data,$$==null)?undefined:$$[$$scope.kk]) + $$scope.someKey],$$==null)?undefined:($$=$$.key,$$==null)?undefined:$$[$$scope.kk]) + "xx\\"x" + $$scope.suffix']
    pars 'data.user[some.data[kk] + someKey].key[kk]= suffix', ['$$scope.data.user[(($$=$$scope.some,$$==null)?undefined:($$=$$.data,$$==null)?undefined:$$[$$scope.kk]) + $$scope.someKey].key[$$scope.kk]= $$scope.suffix']
    pars 'data.user[k1](some.data[k2] + someKey)', ['(($$=$$scope.data,$$==null)?undefined:$$.user).[$$scope.k1]((($$=$$scope.some,$$==null)?undefined:($$=$$.data,$$==null)?undefined:$$[$$scope.k2]) + $$scope.someKey)']

    $test.close()


Test('parsText').run ($test, alight) ->
    $test.start 5

    r = alight.utils.parsText '  {{a}} {{b}}  '
    $test.check r[0].value is '  ' and r[1].list[0] is 'a' and r[2].value is ' ' and r[3].list[0] is 'b' and r[4].value is '  '

    r = alight.utils.parsText '  {{a}}{{b}}  '
    $test.check r[0].value is '  ' and r[1].list[0] is 'a' and r[2].list[0] is 'b' and r[3].value is '  '

    r = alight.utils.parsText '{{a}}{{b}}'
    $test.check r[0].list[0] is 'a' and r[1].list[0] is 'b'

    r = alight.utils.parsText "label {{#get tag.ref -> items.css, $value || 'label-default'}}"
    $test.equal r[0].value, 'label '
    $test.equal r[1].list[0], "#get tag.ref -> items.css, $value || 'label-default'"

    $test.close()
