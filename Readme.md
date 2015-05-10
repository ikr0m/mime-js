mime-js
=======

Sometimes you need to create MIME message in browser. With *mime-js* you can create expected MIME message text.

Install
-------

Run from terminal:

`npm install`
`gulp`

Usage
-----

Call **Mime.toMimeTxt** function with *mail* object:

```javascript  
var mail = {  
    "to": "email1@example.com, email2@example.com",
    "subject": "Today is rainy",
    "fromName": "John Smith",
    "from": "john.smith@mail.com",
    "body": "Sample body text",
    "cids": [],
    "attaches" : []
}
createMimeMessage(mail);
```

***Result:***

```
MIME-Version: 1.0
Date: Sat, 18 Oct 2014 10:33:33 +0000
Delivered-To: email1@example.com
Message-ID: <24jzegg8ghiod2t9ceku9gck746uhaor@mail.your-domain.com>
Subject: =?UTF-8?B?VG9kYXkgaXMgcmFpbnk=?=
From: =?UTF-8?B?Sm9obiBTbWl0aA==?= <john.smith@mail.com>
To: email1@example.com
Content-Type: multipart/mixed; boundary=ko4nd8p2ef2bj4i29277j78q0azto6r

--ko4nd8p2ef2bj4i29277j78q0azto6r
Content-Type: multipart/related; boundary=lwayf4vfgfhcl3dipsq6t2hoaa2rcnmi

--lwayf4vfgfhcl3dipsq6t2hoaa2rcnmi
Content-Type: multipart/alternative; boundary=6ghtwcxztyidaemiv0gzjnw8un8z1tt9

--6ghtwcxztyidaemiv0gzjnw8un8z1tt9
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64

U2FtcGxlIGJvZHkgdGV4dA==

--6ghtwcxztyidaemiv0gzjnw8un8z1tt9
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: base64

PGRpdj5TYW1wbGUgYm9keSB0ZXh0PC9kaXY+

--6ghtwcxztyidaemiv0gzjnw8un8z1tt9--
--lwayf4vfgfhcl3dipsq6t2hoaa2rcnmi--
--ko4nd8p2ef2bj4i29277j78q0azto6r--
```

**cids** - For inline images  
**attaches** - any file in base64 format
