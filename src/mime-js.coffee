###
    mime-js.js 0.1
    2014-10-18

    By Ikrom, https://github.com/ikr0m
    License: X11/MIT
###

window.Mime = do ->
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
    _random = ->
      Math.random().toString(36).slice(2)
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

  createMixed = (related, attaches, mail) ->
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
        '\nContent-Type: multipart/mixed; boundary=' + boundary +
        '\n\n--' + boundary + related

    for attach in attaches
      mimeStr += ('\n--' + boundary + attach)

    (mimeStr + '\n--' + boundary + '--').replace /\n/g, '\r\n'

  createMimeStr = (mail) ->
    plain = createPlain mail.body
    htm = createHtml mail
    alternative = createAlternative plain, htm
    cids = createCids mail.cids
    related = createRelated alternative, cids
    attaches = createAttaches mail.attaches

    result = createMixed related, attaches, mail

    result

  {
    toMimeTxt: createMimeStr
  }

