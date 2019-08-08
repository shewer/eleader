require 'singleton'
module Eleader
  Encode= ['utf-8','big5']
  Dll_path= File.expand_path("../t4",__FILE__ )
  require "eleader/version"
  require "eleader/t4dll"
  require "eleader/struct"
  class Error < StandardError; end
  class InitError < StandardError; end
  class AccountCAError < StandardError; end
  class VerifyCAError < StandardError; end
  # Your code goes here...
  def self.API(account=nil)
    if account.nil?
      API.instance
    else 
      API.instance.account(account)
    end 
  end  

  class API
    include Singleton
    def account(account)
      @branch=account[:branch] || ""
      @account=account[:account] || ""
      @password=account[:password] || ""
      @id=account[:id] || ""
      @key_path=account[:key_path] || ""
      @ca_password=account[:ca_password] || ""
      self


    end
    def to_h
      {
        branch: @branch,
        account: @account,
        password: @password,
        id: @id,
        key_path: @key_path,
        ca_password: @ca_password 
      }
    end 
    def to_yaml
      to_h.to_yaml
    end 
    def save(file="./setup.yaml")
      File.write(file,to_yaml)
    end 
    def check_nil?()
      ! to_h.select{|k,v| v.nil? }.size.zero? 
    end 
    def login
      res=[]
      if not check_nil? 
        ret_str = Eleader::APIfunction.init_t4( @id, @password, '') 
        res.push ret_str
        raise  InitError , ret_str.encode(* Encode)  if ret_str.match?(/Error/)

        ret_str = Eleader::APIfunction.add_acc_ca(@branch,@account,@id,@key_path,@ca_password)
        res.push ret_str
        raise  AccountCAError , ret_str.encode(*Encode)  if ret_str.match?(/Error/)

        ret_str=Eleader::APIfunction.verify_ca_pass(@branch,@account)
        res.push ret_str
        raise  VerifyCAError , ret_str  if ret_str.match?(/Error/)
      else
        res.push "account data value nil"
      end 
      return res.join("\n").encode(*Encode)
    end

    def logout
      APIfunction.log_out().zero?
    end 

    def response()   # return table1
      Structs[:table1].parse APIfunction.get_response()
    end 
    def fo_day_info() # return table5
      Structs[:table5].parse APIfunction.fo_get_day_info(@branch,@account) 
    end 
    def fo_hist_info(date_s,date_e)  #table6
      Structs[:table6].parse APIfunction.fo_get_hist_info(@branch,@account,date_s,date_e )
    end 
    def get_response_log()
      Structs[:table3].parse APIfunction.get_response_log()
    end 
    def timer_response_log()
      Structs[:table3].parse APIfunction.timer_response_log()
    end 
    def fifo_response
      APIfunction.fifo_response()
    end 

    def unsettled_qry(ord)
      if ord.respond_to?(:unsettled)
        ord.unsettled
      else 
        case ord[:ord_prod]
        when :future
          fo_unsettled_qry(ord)
        else 
          warn "Warnning: ord[:ord_prod]:<# #{ord[:ord_prod].class}: (#{ord[:ord_prod]})> not match "
        end 
      end 

    end 
    def fo_unsettled_qry(ord)   #return table1 
      str_ar=[ ord[:flag],ord[:leng],ord[:next],ord[:prev],ord[:gubn],ord[:group_name],@branch,@account,ord[:type_1],
               ord[:type_2],ord[:time_out] ].map(&:to_s)
      Structs[:table11].parse APIfunction.fo_unsettled_qry(* str_ar)

    end 
    def query(ord)
      if ord.respond_to?(:query)
        ord.query
      else 
        case ord[:ord_prod]
        when :future 
          future_query(ord)
        else 
          warn "Warnning: ord[:ord_prod]:<# #{ord[:ord_prod].class}: (#{ord[:ord_prod]})> not match "
        end 
      end
    end 
    def future_query(ord)
      str_ar=[@branch,@account,ord[:code],ord[:ord_match_flag],ord[:ord_type],ord[:oct_type],ord[:daily],ord[:start_date],
              ord[:end_date] ,ord[:preorder],ord[:source] .map(&:to_s)
      ]
      Structs[:table7].parse APIfunction.fo_order_qry2(* str_ar)
    end 

    def order(ord)
      if ord.respond_to?(:order)
        ord.order
      else
        case ord[:ord_prod]
        when :future  
          future_order(ord)
        else 
          warn "Warnning: ord[:ord_prod]:<# #{ord[:ord_prod].class}: (#{ord[:ord_prod]})> not match "
        end 
      end 
    end 
    def future_order(ord)
      str_ar=[ord[:ord_bs],@branch,@account,ord[:code],ord[:price],ord[:amount],ord[:price_type],ord[:ordtype],ord[:octtype]]
      Structs[:table10].parse  APIfunction.future_order(* str_ar ).map(&:to_s)
    end 

    def cancel(ord)
      if ord.respond_to?(:order)
        ord.order
      else
        case ord[:ord_prod]
        when :future  
          future_cancel(ord)
        else 
          warn "Warnning: ord[:ord_prod]:<# #{ord[:ord_prod].class}: (#{ord[:ord_prod]})> not match "
        end 
      end 

    end 
    def future_cancel(ord)
      str_ar=[@branch , @account , ord[:code],ord[:ord_seq],ord[:ord_no],ord[:octtype],ord[:pre_order] ].map(&:to_s)
      Structs[:table10].parse APIfunction.future_cancel(* str_ar)

    end 
  end 
  class Future

    def initialize(hash)
      @data=hash 

    end 


  end 
end
