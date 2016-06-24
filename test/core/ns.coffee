
Test('ns-0', 'ns-0').run ($test, alight) ->
    $test.start 4
    f$ = alight.f$

    # ut-test3
    do ->
        el = ttDOM '<p ut-test3="linux"></p>'

        alight.directives.ut =
            test3: (scope, el, name) ->
                el.textContent = name

        alight.bootstrap el
        $test.equal ttGetText(el), 'linux'

    # $ns.ut-test3
    do ->
        scope =
            $ns:
                directives:
                    ut:
                        uniqDirective: (scope, el, name) ->
                            el.textContent = name

        try
            alight.bootstrap ttDOM('<p ut-test3="linux"></p>'), scope
            $test.error '$ns error'
        catch e
            $test.equal e, 'Directive not found: ut-test3'

        el = ttDOM '<p ut-test3="linux"></p>'
        alight.bootstrap el
        $test.equal ttGetText(el), 'linux'

    # filter
    do ->
        scope =
            $ns:
                filters:
                    double: ->
                        'linux'

        el = ttDOM '<p>{{x | double}}</p>'

        alight.bootstrap el, scope
        $test.equal ttGetText(el), 'linux'

        $test.close()


Test('ns-1', 'ns-1').run ($test, alight) ->
    $test.start 2
    f$ = alight.f$

    tag = ttDOM '<p al-private="title"></p>:<p al-text="title"></p>'
    makeScope = ->
        title: 'title'
        $ns:
            directives:
                al:
                    private: (scope, el, name) ->
                        el.textContent = name

    try
        alight.bootstrap tag, makeScope()
    catch e
        $test.equal e, 'Directive not found: al-text'


    tag = ttDOM '<p al-private="title"></p>:<p al-text="title"></p>'

    scope = makeScope()
    scope.$ns.inheritGlobal = true
    alight.bootstrap tag, scope

    $test.equal ttGetText(tag), 'title:title'
    $test.close()


Test('$global-0').run ($test, alight) ->
    $test.start 2

    el = ttDOM """
        <div>
            <top>
                top={{value0}}
                <middle>
                    <inner>inner={{value1}}</inner>
                </middle>
            </top>
        </div>
    """

    result = ''

    alight.d.$global.top =
        restrict: 'E'
        init: (scope, element) ->
            scope.value0 = 'TOP'
            result += 'top'

    alight.d.$global.inner =
        restrict: 'E'
        init: (scope, element) ->
            scope.value1 = 'INNER'
            result += 'inner'

    alight.bootstrap el

    $test.equal result, 'topinner'
    $test.equal ttGetText(el), 'top=TOP inner=INNER'

    $test.close()


Test('$global-1').run ($test, alight) ->
    $test.start 1

    el = ttDOM """
        <aa-div>{{name}}</aa-div>
    """

    alight.bootstrap el,
        name: 'linux'

    $test.equal ttGetText(el), 'linux'

    $test.close()


Test('$global-2').run ($test, alight) ->
    $test.start 1

    el = ttDOM """
        <aa-div>{{name}}</aa-div>
    """

    alight.d.aa = {}

    try
        alight.bootstrap el,
            name: 'linux'
    catch e
        $test.equal e, 'Directive not found: aa-div'

    $test.close()


Test('$global-3').run ($test, alight) ->
    $test.start 1

    el = ttDOM """
        <aa-div>{{name}}</aa-div>
    """

    alight.d.aa =
        restrict: 'E'
        init: (scope, element) ->
            scope.name = 'Ubuntu'

    try
        alight.bootstrap el
    catch e
        $test.equal e, 'Directive not found: aa-div'

    $test.close()
