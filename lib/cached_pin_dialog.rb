require 'java'

#require_relative 'config_file'
require_relative 'java/smartcardsign-1.0.0.jar'
java_import 'com.itextpdf.smartcard.PinProvider'
java_import 'javax.smartcardio.CardException'
java_import 'com.itextpdf.smartcard.PinDialog'

class CachedPinDialog
  java_implements 'com.itextpdf.smartcard.PinProvider'

  def initialize(digits)
    @digits = digits
    @pin_dialog = PinDialog.new(@digits)
    @last_valid_pin = nil
    @last_pin_check = nil
  end

  #java_signature 'char[] getPin(int retries)'
  def get_pin(retries)
    get_last_valid_pin(retries)
  end

  private

  def get_last_valid_pin(retries)
    if (@last_pin_check.nil? ||
        @last_valid_pin.nil? ||
        @last_valid_pin == "\0".ord ||
        ((Time.now - @last_pin_check).round / 60) > 15)
        #((Time.now - @last_pin_check).round / 60) > (ConfigFile[:pin_valid_for].to_i || 15))
      @last_valid_pin = nil
      @last_pin_check = Time.now
    end

    if @last_valid_pin.nil?
      pin = @pin_dialog.get_pin(retries)
      @last_valid_pin = pin.map {|d| d.chr}.join
    end

    @last_valid_pin.to_java.to_char_array
  end
end