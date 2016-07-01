do ->
    alight.hooks.attribute.unshift
        code: 'events'
        fn: ->
            d = @.attrName.match /^\@([\w\.\-]+)$/
            if not d
                return

            @.ns = 'al'
            @.name = 'on'
            @.attrArgument = d[1]
            return

    ###
    eventModifier
        = 'keydown blur'
        = ['keydown', 'blur']
        =
            event: string or list
            fn: (event, env) ->
    ###

    alight.hooks.eventModifier = {}

    setKeyModifier = (name, key) ->
        alight.hooks.eventModifier[name] =
            event: ['keydown', 'keypress', 'keyup']
            fn: (event, env) ->
                if not event[key]
                    env.stop = true
                return

    setKeyModifier 'alt', 'altKey'
    setKeyModifier 'control', 'ctrlKey'
    setKeyModifier 'ctrl', 'ctrlKey'
    setKeyModifier 'meta', 'metaKey'
    setKeyModifier 'shift', 'shiftKey'

    formatModifier = (modifier, filterByEvents) ->
        result = {}
        if typeof(modifier) is 'string'
            result.event = modifier
        else if typeof(modifier) is 'object' and modifier.event
            result.event = modifier.event

        if typeof(result.event) is 'string'
            result.event = result.event.split /\s+/

        if filterByEvents
            if result.event
                inuse = false
                for e in result.event
                    if filterByEvents.indexOf(e) >= 0
                        inuse = true
                        break
                if not inuse
                    return null

        if f$.isFunction modifier
            result.fn = modifier
        else if modifier.fn
            result.fn = modifier.fn

        if modifier.init
            result.init = modifier.init

        result

    alight.d.al.on =
        priority: 10
        init: (scope, element, expression, env) ->
            if not env.attrArgument
                return
            event = env.attrArgument.split('.')[0]
            handler = makeEvent env.attrArgument, directiveOption[event]
            handler scope, element, expression, env

    keyCodes =
        enter: 13
        tab: 9
        delete: 46
        backspace: 8
        esc: 27
        space: 32
        up: 38
        down: 40
        left: 37
        right: 39

    makeEvent = (attrArgument, option) ->
        option = option or {}
        args = attrArgument.split '.'
        eventName = args[0]
        eventList = null
        stop = option.stop or false
        prevent = option.prevent or false
        scan = true
        modifiers = []
        filterByKey = null
        throttle = null
        throttleId = null
        debounce = null
        debounceTime = 0
        initFn = null

        modifier = alight.hooks.eventModifier[eventName]
        if modifier
            modifier = formatModifier modifier
            if modifier.event
                eventList = modifier.event
                if modifier.fn
                    modifiers.push modifier
                if modifier.init
                    initFn = modifier.init
        if not eventList
            eventList = [eventName]

        for k in args.slice(1)
            if k is 'stop'
                stop = true
                continue
            if k is 'prevent'
                prevent = true
                continue
            if k is 'nostop'
                stop = false
                continue
            if k is 'noprevent'
                prevent = false
                continue
            if k is 'noscan'
                scan = false
                continue
            if k.substring(0, 9) is 'throttle-'
                throttle = Number k.substring 9
                continue
            if k.substring(0, 9) is 'debounce-'
                debounce = Number k.substring 9
                continue

            modifier = alight.hooks.eventModifier[k]
            if modifier
                modifier = formatModifier modifier, eventList
                if modifier
                    modifiers.push modifier
                continue

            if not option.filterByKey
                continue

            if filterByKey is null
                filterByKey = {}

            if keyCodes[k]
                k = keyCodes[k]
            filterByKey[k] = true

        (scope, element, expression, env) ->
            cd = env.changeDetector
            fn = cd.compile expression,
                no_return: true
                input: ['$event', '$element', '$value']

            if element.type is 'checkbox'
                getValue = ->
                    element.checked
            else if element.type is 'radio'
                getValue = ->
                    element.value or element.checked
            else
                getValue = ->
                    element.value

            execute = (event) ->
                try
                    fn cd.locals, event, element, getValue()
                catch error
                    alight.exceptionHandler error, "Error in event: #{attrArgument} = #{expression}",
                        attr: attrArgument
                        exp: expression
                        scope: scope
                        cd: cd
                        element: element
                        event: event
                if scan
                    cd.scan()
                return

            handler = (event) ->
                if filterByKey
                    if not filterByKey[event.keyCode]
                        return

                if modifiers.length
                    env =
                        stop: false
                    for modifier in modifiers
                        modifier.fn event, env
                        if env.stop
                            return

                if prevent
                    event.preventDefault()
                if stop
                    event.stopPropagation()

                if throttle
                    if throttleId
                        clearTimeout throttleId
                    throttleId = setTimeout ->
                        throttleId = null
                        execute event
                    , throttle
                else if debounce
                    if debounceTime < Date.now()
                        debounceTime = Date.now() + debounce
                        execute event
                else
                    execute event
                return

            for e in eventList
                f$.on element, e, handler
            if initFn
                initFn scope, element, expression, env
            cd.watch '$destroy', ->
                for e in eventList
                    f$.off element, e, handler
            return

    directiveOption =
        click:
            stop: true
            prevent: true
        dblclick:
            stop: true
            prevent: true
        submit:
            stop: true
            prevent: true
        keyup:
            filterByKey: true
        keypress:
            filterByKey: true
        keydown:
            filterByKey: true
