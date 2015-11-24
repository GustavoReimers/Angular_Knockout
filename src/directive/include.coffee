
alight.d.al.include =
    priority: 100
    init: (cd, element, name, env) ->
        child = null
        baseElement = null
        topElement = null
        activeElement = null
        self =
            owner: true
            start: ->
                self.prepare()
                self.watchModel()
            prepare: ->
                baseElement = element
                topElement = f$.createComment " #{env.attrName}: #{name} "
                f$.before element, topElement
                f$.remove element
            loadHtml: (cfg) ->
                f$.ajax cfg
            removeBlock: ->
                if child
                    child.destroy()
                    child = null
                if activeElement
                    self.removeDom activeElement
                    activeElement = null
            insertBlock: (html) ->
                activeElement = f$.clone baseElement
                f$.html activeElement, html
                self.insertDom topElement, activeElement
                child = cd.new()
                alight.applyBindings child, activeElement,
                    skip_attr:env.skippedAttr()
            updateDom: (url) ->
                if not url
                    self.removeBlock()
                    return '$scanNoChanges'
                self.loadHtml
                    cache: true
                    url: url
                    success: (html) ->
                        self.removeBlock()
                        self.insertBlock html
                    error: self.removeBlock
                '$scanNoChanges'
            removeDom: (element) ->
                f$.remove element
            insertDom: (base, element) ->
                f$.after base, element
            watchModel: ->
                cd.watch name, self.updateDom

        self
