require 'java'
require_relative 'java/itextpdf-5.5.4.jar'

java_import 'com.itextpdf.text.pdf.PdfReader'
java_import 'com.itextpdf.text.pdf.PdfStamper'
java_import 'com.itextpdf.text.pdf.PdfSignatureAppearance'
java_import 'com.itextpdf.text.Rectangle'
java_import 'com.itextpdf.text.Image'

class Pdf
  def self.sign(in_file, out_file, signature, reason, location, signature_image = nil)
    reader = PdfReader.new(in_file)
    writer = File.new(out_file, 'wb').to_outputstream
    stamper = PdfStamper.create_signature(reader, writer, "\0".ord)

    app = stamper.get_signature_appearance
    app.reason = reason
    app.location = location
    width = reader.get_page_size(1).get_width
    app.set_visible_signature(Rectangle.new(10, 10, width - 10, 80),1,'sig')
    if !signature_image.nil? && File.exists?(signature_image)
      image = Image.get_instance(File.read(signature_image).to_java_bytes)
      image.scale_absolute_height(30.0)
      app.set_rendering_mode(PdfSignatureAppearance::RenderingMode::GRAPHIC_AND_DESCRIPTION)
      app.set_signature_graphic(image)
    end

    signature.sign(app)

  end
end