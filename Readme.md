mime-js
=======

Sometimes you need to create MIME message in browser. With *mime-js* you can create expected MIME message text.

Install
-------

Run from terminal:

`npm install`

`gulp`

Sample Usage
------------

Mime object has two public methods: Mime.toMimeTxt() and Mime.toMimeObj(). See sample and its result.


```javascript  
var originalMail = {
    "to": "email1@example.com",
    "cc": "email2@example.com",
    "subject": "Today is rainy",
    "fromName": "John Smith",
    "from": "john.smith@mail.com",
    "body": "Sample body text",
    "cids": [],
    "attaches" : []
};
var mimeTxt = Mime.toMimeTxt(originalMail);
var mimeObj = Mime.toMimeObj(mimeTxt);
console.log(mimeTxt);
console.log(mimeObj);

```

**Result**

MimeTxt
-------

```
MIME-Version: 1.0
Date: Sun, 10 May 2015 11:50:39 +0000
Message-ID: <i2ozrb4lgrgrpb9hp8wrf4n449xjemi@mail.your-domain.com>
Subject: =?UTF-8?B?VG9kYXkgaXMgcmFpbnk=?=
From: =?UTF-8?B?Sm9obiBTbWl0aA==?= <john.smith@mail.com>
To: email1@example.com
Cc: email2@example.com
Content-Type: multipart/mixed; boundary=qr7c8bjwkc81if6r9xpqmra8rrudi

--qr7c8bjwkc81if6r9xpqmra8rrudi
Content-Type: multipart/related; boundary=zh0eu0iqfdtv5cdiqigyhqinn1r79zfr

--zh0eu0iqfdtv5cdiqigyhqinn1r79zfr
Content-Type: multipart/alternative; boundary=56ksn4vpquissjorg32seupolt4eu3di

--56ksn4vpquissjorg32seupolt4eu3di
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64

U2FtcGxlIGJvZHkgdGV4dA==

--56ksn4vpquissjorg32seupolt4eu3di
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: base64

PGRpdj5TYW1wbGUgYm9keSB0ZXh0PC9kaXY+

--56ksn4vpquissjorg32seupolt4eu3di--
--zh0eu0iqfdtv5cdiqigyhqinn1r79zfr--
--qr7c8bjwkc81if6r9xpqmra8rrudi--
```


MimeObj
-------

```javascript
{"html":"<div>Sample body text</div>","text":"Sample body text","attaches":[],"innerMsgs":[],"to":"email1@example.com","cc":"email2@example.com","from":"John Smith <john.smith@mail.com>","subject":"Today is rainy"}
```

------------------------------------------------------------------

**cids** - For inline images  
**attaches** - any file in base64 format

------------------------------------------------------------------
