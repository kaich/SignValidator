require "SignValidator/version"
require 'optparse'
require 'plist'
require 'colorize'

module SignValidator
  # Your code goes here...
  def self.run 
     @options = {}
     option_parser = OptionParser.new do |opts|
       opts.banner = "signvalidator -c [cert] -p [provision] -u [udid] 校验证书和配置文件是否匹配"
       @options[:cert] = ""
       @options[:provision] = "" 
       @options[:udid] = "" 
       @options[:password] = "123" 

       opts.on('-c cert','--cert p12_cert','用于签名的证书') do |value|
         @options[:cert] = value
       end

      opts.on('-m mobileprovision', '--provision mobileprovision', '用于签名的配置文件') do |value| 
        @options[:provision] = value  
      end

      opts.on('-u udid', '--udid device_udid', '用于检测配置文件是否匹配该设备') do |value| 
        @options[:udid] = value  
      end

      opts.on('-p password', '--password p12_password', 'p12密码') do |value| 
        @options[:password] = value  
      end
     end.parse!

     temp_dir = "#{Dir.home}/Library/SignValidator"
     p12_temp_pem = temp_dir + "/cert.pem"
     provision_temp_cert = temp_dir + "/provision_cert"
     p12_temp_cert = temp_dir + "/p12_cert"

     if !Dir.exist? temp_dir
       Dir.mkdir  temp_dir 
     end

     #get p12 cert data
     isok = system "openssl pkcs12 -in #{@options[:cert]}  -clcerts -nokeys -out #{p12_temp_pem} -password #{@options[:password]}"

     if !isok 
       puts "#{code}提取p12内容失败".colorize(:red)
     end

     pem_content = File.read p12_temp_pem  

     start_marker = "-----BEGIN CERTIFICATE-----"
     end_marker = "-----END CERTIFICATE-----"

     pem_cert_data = pem_content[/#{start_marker}(.*?)#{end_marker}/m , 1]

     pem_cert_data = pem_cert_data.gsub /[\n\r ]/,""
     f = File.new p12_temp_cert,"w"
     f.write pem_cert_data
     f.close


     #get provision cert data 
     provision_content = File.read @options[:provision] 
     provision_content = to_utf8 provision_content
     
     plist_start_marker = '<\?xml version="1.0" encoding="UTF-8"\?>'
     plist_end_marker = '<\/plist>'

     plist_content = provision_content[/#{plist_start_marker}.*#{plist_end_marker}/m]
     provision_plist = Plist::parse_xml plist_content
     provision_certs = provision_plist["DeveloperCertificates"]

     is_valid = false
     provision_certs.each do |cert_data| 
       cert_data = Base64.encode64(cert_data.string).gsub /[\n\r ]/,""
       if cert_data == pem_cert_data
         is_valid  = true
         break
       else 
         file = File.new provision_temp_cert,"w"
         file.write content
         file.close
       end
     end

     is_device_ok = true
     if !@options[:udid].empty?
       provision_devices = provision_plist["ProvisionedDevices"]
       is_device_ok = provision_devices.include? @options[:udid]
     end 


     if is_valid && is_device_ok
        puts "证书和配置文件匹配，校验成功!".colorize(:green)
     elsif is_valid && !is_device_ok
       puts "设备列表:\n".colorize(:yellow)
       provision_devices.each do |udid|
         puts udid
       end
       puts "证书和配置文件匹配,但与该设备不匹配，校验失败!".colorize(:red)
     else 
       puts "证书和配置文件不匹配，校验失败!".colorize(:red) 
     end


  end


  def self.to_utf8(str)
    str = str.force_encoding('UTF-8')
    return str if str.valid_encoding?
    str.encode("UTF-8", 'binary', invalid: :replace, undef: :replace, replace: '')
  end
  

end
