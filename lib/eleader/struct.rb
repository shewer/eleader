#!/usr/bin/env ruby
#
# struct.rb
# Copyright (C) 2019 Shewer Lu <shewer@gmail.com>
#
# Distributed under terms of the MIT license.
#
#require 'abstraction'

module Eleader
  class ReturnError < StandardError; end
  class ReturnSizeError < StandardError; end 
  class EStruct < Struct 
    def initialize(*ar)
      super(*ar)
      conver
    end 
    def conver
      #self[:price]= self[:price].to_f/ 1000_000.0
    end 
    class <<self   
      attr_reader :size ,:fmt,:name 
      def parse(str)
        raise ReturnError.new  str.encode(* Eleader::Encode) if str.match?(/Error/)
        raise ReturnSizeError.new  str.encode(* Eleader::Encode) unless  checksize( str.size )
        ar= self.unpack( str  )
        self.new(* ar   )
      end 
      def checksize(size)
        self.size == size 
      end 
      def size 
        @size
      end 
      def fmt
        @fmt
      end 

      def unpack(str)
        str.unpack(self.fmt)
      end 
    end 
  end 
  class Record < Struct# .new(:head,:records) 
    def count()
      return  records.size if  head[:count].to_i ==   records.size
    end 
    class << self 
      attr_reader :head,:record ,:name
      def records(size)
        s,q=(size-@head.size ).divmod( @record.size )
        q.zero? ? s : nil 

      end 
      def parse(str)

        raise ReturnError.new  str.encode(*Eleader::Encode) if str.match?(/Error/)
        raise ReturnSizeError.new  str.encode(*Eleader::Encode) if  (size_r= records(str.size) ).nil?
        return nil  if size_r.zero? 
        head_str,*records_str=str.unpack("a#{@head.size}" + "a#{@record.size}" * size_r )
        self.new( 
                 create_head(head_str),
                 create_records(* records_str)
                )

      end 
      def create_head( str)
        @head.parse(str)
      end
      def create_record(str)
        @record.parse(str)
      end 
      def create_records(*strs)
        strs.map{|str| create_record(str)}
      end 
    end 
  end 
  #aaa=            %i(type cancelqty contractqty orgrprice seq branch account ord_no ord_seq code trade_type trade_class price \
  #contractprice ordknd qty trans_time statusmsg errorcode errormsg web_id account_s oct ord_time agent_id \
  #price_type trf_fld match_seq func_seq )  
  Table={
    table1h:  [ 5, "a5" , %i{ count }],
    table1r:  [236, "a2a5a5a9a8xa7a7a5a6a10a3a2a9a9a3a5a6a20a4a60a3a15aa6a6aa4a8a6",
               %i{ type cancelqty contractqty orgrprice seq branch account ord_no ord_seq code trade_type trade_class price 
                   contractprice ordknd qty trans_time statusmsg errorcode errormsg web_id account_s oct ord_time agent_id 
                   price_type trf_fld match_seq func_seq }  
  ],
  table3: [205, "a2a2a8xa7a7a5a6a10a3a2a9a9a3a5a6a20a4a60a3a15aa6a6aa4",
           %i(type ord_type seq brench account ord_no ord_seq trade_type trade_class price contractprice ordknd qty
              trans_time statusmsg errorcode errormsg web_id account_s oct ord_time agent_id price_type trf_fld )
  ],
  table10: [ 184, "a2xa7a7aa10aaa12a3a4a6a6a3aaa2aa10aaa12a4a8a8a6aa4a60" , 
             %i{ trade_type branch account  f_futopt code f_callput ord_bs ord_price price_type 
                 ord_qty ord_no ord_seq ord_type f_octype f_mttype f_composit c_futopt c_code 
                 c_callput c_buysell c_prcie c_quantity ord_date preord_date ord_time type err_code msg } 
  ], 
  table5h: [18, "a8a6a4", %i{date time count} ],
  table5r: [560, "a20" * 28 , 
            %i{avlamt actbal tgain bgain obgain pmamt apamt tmamt fee ftax otamt cogtamt cmgtamt warnn warnv bidvolume 
               askvolume bequity gdamt equity ogain exrate xgdamt agtamt yequity munet }
  ],
  table6h: [144 , "a20"* 7 + "a4" , %i{fee tax focn inout bid ask ogain count}] ,
  table6r: [303, "a8a15" + "a20"*14 ,
            %i{ tdate acct profit_qty clear_qty fee tax fcon fmiss omiss inout osecu_amt usecu_amt 
                status bid_qty ask_qty ogain }
  ],
  table7h: [43,"a4a4a16a16a3", %i{ flag leng next prev count } ],
  table7r: [193,"xa7a7a6a6a8a8a6a6a10aa3a6a6a6a12a12a60aa3aaa12a4",
            %i{branch account ord_seq ord_no ord_date preord_date ord_time match_time code ord_bs trade_type ord_qty cancel_qty 
               ord_match_qty ord_prcie ordmatch_avg_prc ord_status type ord_type octtype pre_order chg_ord_price err_code } 
  ],
  table11h: [208,"a4"*4 + "a16"* 12,
             %i(flag leng next prev vol_tot set_tot price_tot loss_tot secu_tot keep_tot balance statistic risk 
                otamt_tot mtamt_tot count)
  ],
  table11r: [192,"xa7a7a8a10a6aa2a3a3"+ "a16"* 9 ,
             %i(branch account tdate code ord_no ord_bs ord_type currency fill vol avg_price set_prive price loss secu keep
                otamt mtamt )
  ],
  }
  Table_record={
    table1: [:table1h,:table1r],table5: [:table5h,:table5r] , 
    table6: [:table6h,:table6r] ,table7: [:table7h,:table7r] ,table11: [:table11h,:table11r] , 
  }
  def self.genrecordtab(hash,ref)

    s=hash.map {|k,v|
      [k, genrecord(k,*v[0,2],ref) ]
    }.to_h
    s.merge(ref)
  end 
  def self.genrecord(name ,head,record,hash_structs)
    Record.new("#{name.capitalize}",:head,:records ) do
      # class value 
      #@name=name     
      @head=hash_structs[head]
      @record=hash_structs[record]
    end 
  end 
  def self.gentab(hash)
    h=hash.map{|k,v|
      #st= genstruct(k,*v)

      [k, genstruct(k,*v) ]   
    }.to_h
    
  end 

  def self.genstruct(name ,size,fmt,keys) 
    EStruct.new("#{name.capitalize}", *keys) do
      #@name=name
      @size=size
      @fmt=fmt
    end
    #eval("#{name.capitalize}=st")   # in Eleader scope
  end 
  puts "----- merage "
  #Structs= gentab(Table)
  #Structs_record= genrecordtab(Table_record)
  #Structs.merge Structs_record
  Structs= genrecordtab( Table_record, gentab(Table) )
  puts "------ meraged -------"
=begin
  class RespQuery_hr <EStruct.new(* Table[:table1h][2])
    @size=Table[:table1h][0]
    @fmt=Table[:table1h][1]
  end 
  class RespQuery_rr <EStruct.new(* Table[:table1r][2])
    @size=Table[:table1r][0]
    @fmt=Table[:table1r][1]
  end 
  class Order_res< EStruct.new(* Table[:table10][2] )

    @size=Table[:table10][0]
    @fmt=Table[:table10][1] 
  end
  class Query_hr <EStruct.new(* Table[:table7h][2])
    @size=Table[:table7h][0]
    @fmt=Table[:table7h][1]
  end 
  class Query_rr <EStruct.new(* Table[:table7r][2])
    @size=Table[:table7r][0]
    @fmt=Table[:table7r][1]
  end 

  class Order_qry <Record.new(:head,:records)
    @head=Query_hr
    @record=Query_rr

  end 
=end 
end 
if __FILE__ == $0
  #require 'yaml'
  ##res=YAML.load_file("./tmp/res.txt")
  ##a=Eleader::Order_res.parse(res[0])
  ##puts a
end 


