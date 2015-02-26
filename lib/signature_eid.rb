require 'java'

require_relative 'java/smartcardsign-1.0.0.jar'
require_relative 'java/bcpkix-jdk15on-151.jar'
require_relative 'java/bcprov-jdk15on-151.jar'
require_relative 'java/itextpdf-5.5.4.jar'
require_relative 'cached_pin_dialog'
require 'stringio'

java_import 'java.security.Security'
java_import 'org.bouncycastle.jce.provider.BouncyCastleProvider'

java_import 'com.itextpdf.smartcard.CardReaders'
java_import 'com.itextpdf.smartcard.beid.BeIDCard'
#java_import 'com.itextpdf.smartcard.PinDialog'
java_import 'com.itextpdf.smartcard.beid.BeIDCertificates'
java_import 'com.itextpdf.smartcard.EidSignature'

java_import 'com.itextpdf.text.pdf.security.BouncyCastleDigest'
java_import 'com.itextpdf.text.pdf.security.DigestAlgorithms'
java_import 'com.itextpdf.text.pdf.security.MakeSignature'
java_import 'com.itextpdf.text.pdf.security.CrlClientOnline'
java_import 'com.itextpdf.text.pdf.security.OcspClientBouncyCastle'
java_import 'com.itextpdf.text.pdf.security.CertificateUtil'

class SignatureEid
  def initialize
    readers = CardReaders.new

    raise "No reader WITH card found!" if readers && readers.get_readers_with_card.length == 0

    @card    = BeIDCard.new(readers.get_readers_with_card.first)
    #card.pin_provider = PinDialog.new(4)
    @card.pin_provider = CachedPinDialog.new(4)

    @provider = BouncyCastleProvider.new

    Security.add_provider(@provider)
  end

  def sign(app)
    digest_algorithm = DigestAlgorithms::SHA256
    chain = BeIDCertificates.get_sign_certificate_chain(@card)
    eid = EidSignature.new(@card, digest_algorithm, @provider.name)

    crl_list = [CrlClientOnline.new(chain)]
    ocsp_client = OcspClientBouncyCastle.new

    subfilter = MakeSignature::CryptoStandard::CMS
    digest = BouncyCastleDigest.new

    MakeSignature.sign_detached(app, digest, eid, chain, crl_list, ocsp_client, nil, 0, subfilter)
    return true
  rescue Exception => e
    puts e.message
    return false
  end
end