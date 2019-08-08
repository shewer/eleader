require 'ffi'
require 'yaml'

#raise "you needed setup.yaml File in Work Direction " unless File.exist?("setup.yaml")


module Eleader
  def self.init_dllfile()
    if Object.const_defined?("DLL_FILE") 
      DLL_FILE 
      return dllfile if File.exist?(dllfile)
    else 
      setup_file= Dir.pwd << "/setup.yaml"
      warn  "[33mDLL_FILE dosen't define : load #{setup_file} [0m]"  
      dllfile=   YAML.load_file( setup_file )[:dllfile] if File.exist?(setup_file)
      return dllfile if File.exist?(dllfile)
    end 
    dllfile= File.expand_path("./t4.dll",Dir.pwd)
    return dllfile if File.exist?(dllfile)
    dllfile= File.expand_path("../../t4.dll",__FILE__)
    return dllfile if File.exist?(dllfile)
    dllfile= File.expand_path("./t4.dll","C:/Windows/System32")
    return dllfile if File.exist?(dllfile)
    dllfile= File.expand_path("./t4.dll","C:/Windows/SysWoW64")
    return dllfile if File.exist?(dllfile)
  ensure 
    puts "dllfile : #{dllfile}"
  end 
  module APIfunction 

    #raise "you needed define t4.dll file path in Variabl : DLL_FILE" unless  DLL_FILE
    extend FFI::Library
    ffi_lib Eleader.init_dllfile()              # DLL name  (given)
    #ffi_lib Eleader::Dll_path             # DLL name  (given)
    #ffi_lib '/mnt/d/eleader/dll_10134/t4.dll'              # DLL name  (given)
    ffi_convention :stdcall

    # item 1  init
    attach_function  :init_t4,            # method name  (your choice)
      :init_t4,       # DLL function name (given)
      [ :string,:string,:string], :string  
    # specify C param / return value types 
    attach_function :add_acc_ca,
      :add_acc_ca,
      [:string,:string,:string,:string,:string],:string
    # branch, account accid ca_path , ca_password
    attach_function :verify_ca_pass,
      :verify_ca_pass,[:string,:string],:string



    # item2  order

=begin
BSTR future_order( char*buy_or_sell
, char*branch
, char*account
, char*future_id
, char*price
, char*amount
, char*price_type
, char*ordtype
, char*octtype ); 

  buy_or_sell : "B" = 買, "S" = 賣
branch : 期貨分公司代號
account : 期貨帳戶
future_id : 商品代號
price : 價格 6 位數
amount : 口數 3 位數
price type : "MKT"市價, "LMT" 限價
ordtype: ROD / FOK / IOC
octtype: 倉別 "0" = 新倉 "1" = 平倉 " "= 自動 "6"= 當沖
=end

    attach_function :future_order,
      :future_order, Array.new(9,:string), :string
    # buy_or_sell,branch  ,account,future_id,price,amount,price_type,ordtype,octtype

=begin
BSTR future_cancel( char*branch
, char*account
, char*future_id
, char*ord_seq 
, char*ord_no
, char*octtype
, char*pre_order ); 
  branch : 期貨分公司代號
account : 期貨帳戶
future_id : 商品代號
ord_seq : 網路單號
ord_no : 委託單號
octtype : "0" 新倉, "1" 平倉, " " 自動 "6"= 當沖
pre_order : "N" - 非預約單, " " - 預約單
=end		  

    attach_function	:future_cancel,:future_cancel, Array.new(7,:string), :string

=begin
BSTR future_change ( char*org_seqno
, char*org_ordno
, char*branch
, char*account
, char*commodity
, char*new_price
, char*pre_order ); 
  org_seqno : 原流水書號
org_ordno : 原委託單號
branch : 期貨分公司代號
account : 期貨帳戶
commodity : 期貨商品代號
new_price : 新價格
pre_order : "N" - 非預約單, " " - 預約單
=end
    attach_function :future_change,
      :future_change, Array.new(7,:string),:string

    attach_function :option_order, :option_order , Array.new(12,:string) , :string 
    attach_function :option_cancel, :option_cancel , Array.new(7,:string) , :string 
    attach_function :get_response_log, :get_response_log,[],:string
    attach_function :get_response, :get_response,[],:string
    attach_function :check_response_buffer, :check_response_buffer, [] ,:int
    attach_function :timer_response_log, :timer_response_log, [] ,:string 
    attach_function :fifo_response, :fifo_response, [:pointer ] , :int 
    attach_function :get_response_evt, :get_response_evt ,[:pointer,:int ],:pointer 
    # v other function 
    attach_function :change_echo, :change_echo , [], :string 
    #  0 logout acepect  -1 
    attach_function :log_out, :log_out ,[] , :int 
    attach_function :show_version, :show_version ,[] ,:string 
    attach_function :show_list , :show_list , [] , :string 
    attach_function :show_ip, :show_ip, [], :string 
    # active response  enable/disable (1/0)
    # return  0 / 1 
    attach_function :do_register, :do_register, [:int] , :int 

    attach_function :fo_get_day_info,:fo_get_day_info, [:string,:string] ,:string 
    attach_function :fo_get_hist_info,:fo_get_hist_info, Array.new(4,:string),:string



    # branch, acct, code, ord_match, ord_type,oct_type,daily,start_date, end_date,preorder,source

    attach_function :fo_order_qry2,		:fo_order_qry2, Array.new(11,:string), :string
    #		:fo_order_qry2,[:string,:string,:string,:string,:string,:string,:string,:string,:string,:string,:string],:string

    attach_function :fo_unsettled_qry,  :fo_unsettled_qry,Array.new(11,:string),:string
  end 



end 





# create exception of  Return data size .   
class SizeException < RuntimeError
  #	puts "Size Error"
end




if __FILE__  == $0 

end


