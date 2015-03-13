# BESign
Batch signing PDF documents with a Belgian Electronic id card.

This is a Proof Of Concept not useful in any sense. [iText](http://itextpdf.com) is dual licensed and if you should decide to use BESign then 
please consider buying an iText license(I have no gain in this, btw). You can do whatever you wish with the rest of the code.

```
Usage: java -jar be_sign.jar options
    -r, --reason MANDATORY           Text that states the reason of signing the documents
    -l, --location MANDATORY         Your location
    -s, --signature                  An image of your wet signature
    -i, --inbox MANDATORY            A directory with the files that need to be signed
    -o, --outbox MANDATORY           A directory that holds the signed files
    -h, --help                       Show this message
```

I used [warbler](https://github.com/jruby/warbler) to create to jar file.
