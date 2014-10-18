
/*
    mime-js.js 0.1
    2014-10-18

    By Ikrom, https://github.com/ikr0m
    License: X11/MIT
*/


(function() {

  window.createMimeMessage = function(mail) {
    var alternative, attaches, cids, createAlternative, createAttaches, createCids, createHtml, createMixed, createPlain, createRelated, getBoundary, htm, plain, related;
    getBoundary = function() {
      return Math.random().toString(36).slice(2) + Math.random().toString(36).slice(2);
    };
    createPlain = function(textContent) {
      if (textContent == null) {
        textContent = '';
      }
      return '\nContent-Type: text/plain; charset=UTF-8' + '\nContent-Transfer-Encoding: base64' + '\n\n' + (Base64.encode(textContent, true)).replace(/.{76}/g, "$&\n");
    };
    createHtml = function(msg) {
      var htmlContent;
      htmlContent = msg.body || "";
      htmlContent = htmlContent.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/, '&gt;').replace(/\n/g, '\n<br/>');
      htmlContent = '<div>' + htmlContent + '</div>';
      return '\nContent-Type: text/html; charset=UTF-8' + '\nContent-Transfer-Encoding: base64' + '\n\n' + (Base64.encode(htmlContent, true)).replace(/.{76}/g, "$&\n");
    };
    createAlternative = function(text, html) {
      var boundary;
      boundary = getBoundary();
      return '\nContent-Type: multipart/alternative; boundary=' + boundary + '\n\n--' + boundary + text + '\n\n--' + boundary + html + '\n\n--' + boundary + '--';
    };
    createCids = function(cids) {
      var base64, cid, cidArr, id, name, type, _i, _len;
      if (!cids) {
        return;
      }
      cidArr = [];
      for (_i = 0, _len = cids.length; _i < _len; _i++) {
        cid = cids[_i];
        type = cid.type;
        name = cid.name;
        base64 = cid.base64;
        id = getBoundary();
        cidArr.push('\nContent-Type: ' + type + '; name=\"' + name + '\"' + '\nContent-Transfer-Encoding: base64' + '\nContent-ID: <' + id + '>' + '\nX-Attachment-Id: ' + id + '\n\n' + base64);
      }
      return cidArr;
    };
    createRelated = function(alternative, cids) {
      var boundary, cid, relatedStr, _i, _len;
      if (cids == null) {
        cids = [];
      }
      boundary = getBoundary();
      relatedStr = '\nContent-Type: multipart/related; boundary=' + boundary + '\n\n--' + boundary + alternative;
      for (_i = 0, _len = cids.length; _i < _len; _i++) {
        cid = cids[_i];
        relatedStr += '\n--' + boundary + cid;
      }
      return relatedStr + '\n--' + boundary + '--';
    };
    createAttaches = function(attaches) {
      var attach, base64, id, name, result, type, _i, _len;
      if (!attaches) {
        return;
      }
      result = [];
      for (_i = 0, _len = attaches.length; _i < _len; _i++) {
        attach = attaches[_i];
        type = attach.type;
        name = attach.name;
        base64 = attach.base64;
        id = getBoundary();
        result.push('\nContent-Type: ' + type + '; name=\"' + name + '\"' + '\nContent-Disposition: attachment; filename=\"' + name + '\"' + '\nContent-Transfer-Encoding: base64' + '\nX-Attachment-Id: ' + id + '\n\n' + base64);
      }
      return result;
    };
    createMixed = function(related, attaches) {
      var attach, boundary, date, mailFromName, mimeStr, subject, _i, _len;
      if (attaches == null) {
        attaches = [];
      }
      boundary = getBoundary();
      if (mail.subject) {
        subject = '=?UTF-8?B?' + Base64.encode(mail.subject, true) + '?=';
      }
      if (subject == null) {
        subject = '';
      }
      mailFromName = '=?UTF-8?B?' + Base64.encode(mail.fromName || "", true) + '?=';
      date = (new Date().toGMTString()).replace(/GMT|UTC/gi, '+0000');
      mimeStr = 'MIME-Version: 1.0' + '\nDate: ' + date + '\nDelivered-To: ' + mail.to + '\nMessage-ID: <' + getBoundary() + '@mail.your-domain.com>' + '\nSubject: ' + subject + '\nFrom: ' + mailFromName + ' <' + mail.from + '>' + '\nTo: ' + mail.to + '\nContent-Type: multipart/mixed; boundary=' + boundary + '\n\n--' + boundary + related;
      for (_i = 0, _len = attaches.length; _i < _len; _i++) {
        attach = attaches[_i];
        mimeStr += '\n--' + boundary + attach;
      }
      return (mimeStr + '\n--' + boundary + '--').replace(/\n/g, '\r\n');
    };
    try {
      plain = createPlain(mail.body);
      htm = createHtml(mail);
      alternative = createAlternative(plain, htm);
      cids = createCids(mail.cids);
      related = createRelated(alternative, cids);
      attaches = createAttaches(mail.attaches);
      return createMixed(related, attaches);
    } catch (err) {
      throw new Error(err);
    }
  };

}).call(this);
