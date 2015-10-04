###
    mime-js.js 0.2.0
    2014-10-18

    By Ikrom, https://github.com/ikr0m
    License: X11/MIT
###

window.Mime = do ->

  # *********************************
  # Create Mime Text from Mail Object

#  var mail = {
#    "to": "email1@example.com, email2@example.com",
#    "cc": "email3@example.com, email4@example.com",
#    "subject": "Today is rainy",
#    "fromName": "John Smith",
#    "from": "john.smith@mail.com",
#    "body": "Sample body text",
#    "cids": [],
#    "attaches" : []
#  }
  toMimeTxt = (mail) ->
    linkify = (inputText) ->
      #URLs starting with http://, https://, or ftp://
      replacePattern1 = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim
      replacedText = inputText.replace(replacePattern1,
        "<a href=\"$1\" target=\"_blank\">$1</a>")

      #URLs starting with "www." (without // before it, or it'd re-link the ones done above).
      replacePattern2 = /(^|[^\/])(www\.[\S]+(\b|$))/gim
      replacedText = replacedText.replace(replacePattern2,
        "$1<a href=\"http://$2\" target=\"_blank\">$2</a>")

      replacePattern3 = /(([a-zA-Z0-9\-\_\.])+@[a-zA-Z\_]+?(\.[a-zA-Z]{2,6})+)/gim
      replacedText = replacedText.replace(replacePattern3,
        '<a href="mailto:$1">$1</a>')

      replacedText

    getBoundary = ->
      _random = -> Math.random().toString(36).slice(2)
      _random() + _random()

    createPlain = (textContent = '') ->
      '\nContent-Type: text/plain; charset=UTF-8' +
        '\nContent-Transfer-Encoding: base64' +
        '\n\n' + (Base64.encode textContent, true).replace(/.{76}/g, "$&\n")

    createHtml = (msg) ->
      htmlContent = msg.body || ""
      htmlContent = htmlContent.replace(/&/g, '&amp;').replace(/</g, '&lt;')
      .replace(/>/, '&gt;').replace(/\n/g, '\n<br/>')

      htmlContent = linkify(htmlContent)

      htmlContent = '<div>' + htmlContent + '</div>'
      '\nContent-Type: text/html; charset=UTF-8' +
        '\nContent-Transfer-Encoding: base64' +
        '\n\n' + (Base64.encode htmlContent, true).replace(/.{76}/g, "$&\n")

    createAlternative = (text, html) ->
      boundary = getBoundary()

      '\nContent-Type: multipart/alternative; boundary=' + boundary +
        '\n\n--' + boundary + text +
        '\n\n--' + boundary + html +
        '\n\n--' + boundary + '--'

    createCids = (cids) ->
      return if !cids
      cidArr = []
      for cid in cids
        type = cid.type
        name = cid.name
        base64 = cid.base64
        id = getBoundary()

        cidArr.push '\nContent-Type: ' + type + '; name=\"' + name + '\"' +
          '\nContent-Transfer-Encoding: base64' +
          '\nContent-ID: <' + id + '>' +
          '\nX-Attachment-Id: ' + id +
          '\n\n' + base64
      cidArr

    createRelated = (alternative, cids = []) ->
      boundary = getBoundary()

      relatedStr = '\nContent-Type: multipart/related; boundary=' + boundary +
          '\n\n--' + boundary + alternative
      for cid in cids
        relatedStr += ('\n--' + boundary + cid)

      relatedStr + '\n--' + boundary + '--'

    createAttaches = (attaches) ->
      return if !attaches
      result = []
      for attach in attaches
        type = attach.type
        name = attach.name
        base64 = attach.base64
        id = getBoundary()

        result.push '\nContent-Type: ' + type + '; name=\"' + name + '\"' +
          '\nContent-Disposition: attachment; filename=\"' + name + '\"' +
          '\nContent-Transfer-Encoding: base64' +
          '\nX-Attachment-Id: ' + id +
          '\n\n' + base64
      result

    createMixed = (related, attaches) ->
      boundary = getBoundary()
      subject = ''
      if mail.subject
        subject = '=?UTF-8?B?' + Base64.encode(mail.subject, true) + '?='

      mailFromName = '=?UTF-8?B?' + Base64.encode(mail.fromName || "",
          true) + '?='
      date = (new Date().toGMTString()).replace(/GMT|UTC/gi, '+0000')
      mimeStr = 'MIME-Version: 1.0' +
          '\nDate: ' + date +
          '\nMessage-ID: <' + getBoundary() + '@mail.your-domain.com>' +
          '\nSubject: ' + subject +
          '\nFrom: ' + mailFromName + ' <' + mail.from + '>' +
          '\nTo: ' + mail.to +
          '\nCc: ' + mail.cc +
          '\nContent-Type: multipart/mixed; boundary=' + boundary +
          '\n\n--' + boundary + related

      for attach in attaches
        mimeStr += ('\n--' + boundary + attach)

      (mimeStr + '\n--' + boundary + '--').replace /\n/g, '\r\n'


    plain = createPlain mail.body
    htm = createHtml mail
    alternative = createAlternative plain, htm
    cids = createCids mail.cids
    related = createRelated alternative, cids
    attaches = createAttaches mail.attaches

    result = createMixed(related, attaches)

    result


  # *********************************
  # MailParser helper

  MailParser = (rawMessage) ->
    explodeMessage = (inMessage) ->
      inHeaderPos = inMessage.indexOf("\r\n\r\n")
      if inHeaderPos is -1
        inMessage = inMessage.replace(/\n/g, "\r\n") # Let's give it a try
        inHeaderPos = inMessage.indexOf("\r\n\r\n")
        # empty body
        inHeaderPos = inMessage.length  if inHeaderPos is -1

      inRawHeaders = inMessage.slice(0, inHeaderPos).replace(/\r\n\s+/g, " ") + "\r\n"
      inRawBody = inMessage.slice(inHeaderPos).replace(/(\r\n)+$/, "").replace(/^(\r\n)+/, "")
      inContentType = ""
      regContentType = inRawHeaders.match(/Content-Type: (.*)/i)

      if regContentType and regContentType.length > 0
        inContentType = regContentType[1] # ignore case-sensitive Content-type
      else
        console.log "Warning: MailParser: Content-type doesn't exist!"

      inContentTypeParts = inContentType.split(";")
      mimeType = inContentTypeParts[0].replace(/\s/g, "")
      mimeTypeParts = mimeType.split("/")

      # If it's a multipart we need to split it up
      if mimeTypeParts[0].toLowerCase() is "multipart"
        inBodyParts = []

        #MS sends boundary in 3rd element
        match = inContentTypeParts[1].match(/boundary="?([^"]*)"?/i)
        match = inContentTypeParts[2].match(/boundary="?([^"]*)"?/i)  if not match and inContentTypeParts[2]
        inBoundary = _util.trim(match[1]).replace(/"/g, "")
        escBoundary = inBoundary.replace(/\+/g, "\\+") # We should escape '+' sign
        regString = new RegExp("--" + escBoundary, "g")
        inBodyParts = inRawBody.replace(regString, inBoundary).replace(regString, inBoundary).split(inBoundary)
        inBodyParts.shift()
        inBodyParts.pop()
        i = 0

        while i < inBodyParts.length
          inBodyParts[i] = inBodyParts[i].replace(/(\r\n)+$/, "").replace(/^(\r\n)+/, "")
          inBodyParts[i] = explodeMessage(inBodyParts[i])
          i++
      else
        inBody = inRawBody
        if mimeTypeParts[0] is "text"
          inBody = inBody.replace(RegExp("=\\r\\n", "g"), "")
          specialChars = inBody.match(RegExp("=[A-F0-9][A-F0-9]", "g"))
          if specialChars
            i = 0

            while i < specialChars.length
              inBody = inBody.replace(specialChars[i],
                String.fromCharCode(parseInt(specialChars[i].replace(RegExp("="), ""), 16)))
              i++

      rawHeaders: inRawHeaders
      rawBody: inRawBody
      body: inBody
      contentType: inContentType
      contentTypeParts: inContentTypeParts
      boundary: inBoundary
      bodyParts: inBodyParts
      mimeType: mimeType
      mimeTypeParts: mimeTypeParts

    messageParts = ""
    try
      messageParts = explodeMessage(rawMessage)
    rawHeaders = messageParts.rawHeaders
    getValidStr = (arr = []) ->
      arr[1] or ""

    subject = getValidStr((/\r\nSubject: (.*)\r\n/g).exec(rawHeaders))
    to = getValidStr((/\r\nTo: (.*)\r\n/g).exec(rawHeaders))
    cc = getValidStr((/\r\nCc: (.*)\r\n/g).exec(rawHeaders))
    from = getValidStr((/\r\nFrom: (.*)\r\n/g).exec(rawHeaders))

    {
    messageParts: messageParts
    subject: subject
    to: to
    cc: cc
    from: from
    }


  # ******************************
  # Local Utility

  _util = do ->
    trim = (str = '') ->
      str.trim?() || str.replace(/^\s+|\s+$/g, '')

    decode = (txt = '', charset = '') ->
      charset = charset.toLowerCase()
      result = switch
        when charset.indexOf('koi8-r') isnt -1 then KOIRDec(txt)
        when charset.indexOf('utf-8') isnt -1 then Base64._utf8_decode(txt)
        when charset.indexOf('windows-1251') isnt -1 then win1251Dec(txt)
        else
          txt

      result

    # QuotedPrintable Decode
    QPDec = (s) ->
      s.replace(/\=[\r\n]+/g, "").replace(/\=[0-9A-F]{2}/gi, (v) ->
        String.fromCharCode(parseInt(v.substr(1), 16)))

    KOIRDec = (str) ->
      charmap = unescape(
        "%u2500%u2502%u250C%u2510%u2514%u2518%u251C%u2524%u252C%u2534%u253C%u2580%u2584%u2588%u258C%u2590" +
          "%u2591%u2592%u2593%u2320%u25A0%u2219%u221A%u2248%u2264%u2265%u00A0%u2321%u00B0%u00B2%u00B7%u00F7" +
          "%u2550%u2551%u2552%u0451%u2553%u2554%u2555%u2556%u2557%u2558%u2559%u255A%u255B%u255C%u255D%u255E" +
          "%u255F%u2560%u2561%u0401%u2562%u2563%u2564%u2565%u2566%u2567%u2568%u2569%u256A%u256B%u256C%u00A9" +
          "%u044E%u0430%u0431%u0446%u0434%u0435%u0444%u0433%u0445%u0438%u0439%u043A%u043B%u043C%u043D%u043E" +
          "%u043F%u044F%u0440%u0441%u0442%u0443%u0436%u0432%u044C%u044B%u0437%u0448%u044D%u0449%u0447%u044A" +
          "%u042E%u0410%u0411%u0426%u0414%u0415%u0424%u0413%u0425%u0418%u0419%u041A%u041B%u041C%u041D%u041E" +
          "%u041F%u042F%u0420%u0421%u0422%u0423%u0416%u0412%u042C%u042B%u0417%u0428%u042D%u0429%u0427%u042A")
      code2char = (code) ->
        return charmap.charAt(code - 0x80) if code >= 0x80 and code <= 0xFF
        String.fromCharCode(code)
      res = ""
      for val, i in str
        res = res + code2char str.charCodeAt i

      res

    win1251Dec = (str = '') ->
      result = ''
      for s, i in str
        iCode = str.charCodeAt(i)
        oCode = switch
          when iCode is 168 then 1025
          when iCode is 184 then 1105
          when 191 < iCode < 256 then iCode + 848
          else
            iCode
        result = result + String.fromCharCode(oCode)

      result

    _decodeMimeWord = (str, toCharset) ->
      str = _util.trim(str)
      fromCharset = undefined
      encoding = undefined
      match = undefined
      match = str.match(/^\=\?([\w_\-]+)\?([QqBb])\?([^\?]*)\?\=$/i)
      return decode(str, toCharset) unless match

      fromCharset = match[1]
      encoding = (match[2] or "Q").toString().toUpperCase()
      str = (match[3] or "").replace(/_/g, " ")
      if encoding is "B"
        Base64.decode str, toCharset #, fromCharset
      else if encoding is "Q"
        QPDec str #, toCharset, fromCharset
      else
        str

    decodeMimeWords = (str, toCharset) ->
#      curCharset = undefined
      str = (str or "").toString().replace(/(=\?[^?]+\?[QqBb]\?[^?]+\?=)\s+(?==\?[^?]+\?[QqBb]\?[^?]*\?=)/g, "$1")
      .replace(/\=\?([\w_\-]+)\?([QqBb])\?[^\?]*\?\=/g, ((mimeWord, charset, encoding) ->
#          curCharset = charset + encoding
          _decodeMimeWord mimeWord #, curCharset
        ).bind(this))

      decode str, toCharset

    toHtmlEntity = (txt = "") ->
      (txt + "").replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

    {decode, KOIRDec, win1251Dec, decodeMimeWords, toHtmlEntity, trim}


  # *********************************
  # Create Mail Object from Mime Text


  buildMimeObj = (rawMailObj) ->
    readyMail =
      html: ""
      text: ""
      attaches: []
      innerMsgs: []
      to: _util.decodeMimeWords(rawMailObj.to)
      cc: _util.decodeMimeWords(rawMailObj.cc)
      from: _util.decodeMimeWords rawMailObj.from
      subject: _util.decodeMimeWords rawMailObj.subject

    decodeBody = (body, rawHeaders) ->
      isQP = /Content-Transfer-Encoding: quoted-printable/i.test(rawHeaders)
      isBase64 = /Content-Transfer-Encoding: base64/i.test(rawHeaders)
      if isBase64
        body = body.replace(/\s/g, '')
        decBody = atob?(body)
        decBody ?= Base64.decode(body)
        body = decBody
      else if isQP
        body = _util.QPDec body

      body

    parseBodyParts = (bodyParts) ->
      return if !bodyParts
      for part in bodyParts
        mimeType = (part.mimeType ? "").toLowerCase()
        if mimeType.indexOf('multipart') isnt -1
          parseBodyParts part.bodyParts
          continue

        if mimeType.indexOf('message/rfc822') isnt -1
          newMimeMsg = MailParser(part.rawBody)
          innerMsg = toMimeObj(newMimeMsg)
          readyMail.innerMsgs.push innerMsg
          # txt = innerMsg.text
          # htm = innerMsg.html
          # readyMail.text += txt if txt
          # readyMail.html += htm if htm
          # if innerMsg.attaches?.length > 0
          # readyMail.attaches = readyMail.attaches.concat(innerMsg.attaches)
          continue

        rawHeaders = part.rawHeaders
        isAttach = rawHeaders.indexOf('Content-Disposition: attachment') isnt -1
        body = part.rawBody

        isHtml = /text\/html/.test(mimeType)
        isPlain = /text\/plain/.test(mimeType)
        isImg = /image/.test(mimeType)
        isAudio = /audio/.test(mimeType)
        # isBase64 = /Content-Transfer-Encoding: base64/i.test(rawHeaders)

        if isAttach or isImg or isAudio
          isQP = /Content-Transfer-Encoding: quoted-printable/i.test(rawHeaders)
          if isQP
            body = _util.QPDec body
            body = if btoa then btoa(body) else Base64.encode(body)

#          name = null
          for typePart in part.contentTypeParts
            if /name=/i.test(typePart)
              name = typePart.replace(/(.*)=/, '').replace(/"|'/g, '')
              break

          if !name
            name = if isImg then "image" else if isAudio then "audio" else "attachment"
            name += "_" + Math.floor(Math.random() * 100)
            slashPos = mimeType.indexOf('/')

            type = mimeType.substring(slashPos + 1)

            if type.length < 4
              name += "." + type

          regex = /(.*)content-id:(.*)<(.*)>/i
          attach =
            type: mimeType
            base64: body
            name: name
            cid: regex.exec(rawHeaders)?[3]
            visible: /png|jpeg|jpg|gif/.test(mimeType)

          readyMail.attaches.push attach

        else if isHtml or isPlain
          body = decodeBody body, rawHeaders
          body = _util.decode(body, part.contentType)
          readyMail.html += body if isHtml
          readyMail.text += body if isPlain

        else
          console.log "Unknown mime type: #{mimeType}"

      null

    try
      parts = rawMailObj.messageParts
      if !parts
        return readyMail

      mimeType = (parts.mimeType || "").toLowerCase()
      isText = /text\/plain/.test(mimeType)
      isHtml = /text\/html/.test(mimeType)

      if mimeType.indexOf('multipart') isnt -1
        parseBodyParts parts.bodyParts
      else if isText or isHtml
        body = decodeBody parts.body, parts.rawHeaders
        body = _util.decode body, parts.contentType
        readyMail.html = body if isHtml
        readyMail.text = body if isText
      else
        console.log "Warning: mime type isn't supported! mime=#{mimeType}"

    catch err
      throw new Error err

    wrapPreTag = (txt) ->
      "<pre>" + _util.toHtmlEntity(txt) + "</pre>"

    mergeInnerMsgs = (mail) ->
      innerMsgs = mail.innerMsgs
      if innerMsgs?.length
        if !_util.trim(mail.html) and mail.text
          mail.html += wrapPreTag mail.text

        for innerMsg in innerMsgs
          msg = mergeInnerMsgs innerMsg
          txt = msg.text
          htm = msg.html
          if htm
            mail.html += htm
          else if txt
            mail.html += wrapPerTag txt
            mail.text += txt
          if msg.attaches?.length > 0
            mail.attaches = mail.attaches.concat(msg.attaches)

      mail

    result = mergeInnerMsgs readyMail
    result

  toMimeObj = (mimeMsgText) ->
    rawMailObj = MailParser mimeMsgText
    mailObj    = buildMimeObj rawMailObj
    mailObj

  { toMimeTxt, toMimeObj }
