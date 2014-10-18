mime-js
=======

Sometimes you need to create MIME message in browser. With *mime-js* you can create expected MIME message text. This project is created with Play framework, sbt. 

Usage
-----

Call **createMimeMessage** function with *mail* object:

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

**cids** - For inline images  
**attaches** - any file in base64 format

You may need to look into [mime-js.coffee][1] ([mime-js.js][2])

  [1]: https://github.com/ikr0m/mime-js/blob/master/app/assets/javascripts/mime-js.coffee
  [2]: https://github.com/ikr0m/mime-js/blob/master/public/javascripts/mime-js.js