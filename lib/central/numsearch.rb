class Central
  class Numsearch

    def initialize

    end

    def self.test

      @db = CouchRest.database("http://208.90.213.230:5984/accounts")
      puts @db
      puts @db.view('accounts/_view/listing_by_name')['rows'].inspect

    end


    def lookup(query)
    #Set up
    bigcouchurl = "http://208.90.213.230:5984"
    raccount = Hash.new
    rparent = Hash.new
    rsugar = Hash.new
    rsugarcontact = Hash.new

    if query.match(/[a-z]/)
      #SEARCH BY ACCOUNT NAME
      namesearchraw = `curl -sS "#{bigcouchurl}/accounts/_design/accounts/_view/listing_by_name"`
      namesearchparse = JSON.parse(namesearchraw)
      rows = namesearchparse["rows"]
      for i in 0..namesearchparse["rows"].length.to_i
        if (rows[i]["key"] == query)
          accountid = rows[i]["id"]
          break
        end
      end

    else
      #SEARCH BY PHONE NUMBER
      #FORMAT NUMBER
      digits = query.gsub(/\D/, '').split(//)
      if (digits.length == 11 and digits[0] == '1')
        #STRIP LEADING 1
        digits.shift
      end
      if (digits.length == 10)
        formnum = digits
      else
        puts "Incorrect number format"
        exit
      end
      #CURL FOR NUMBER DOCUMENT IN AREA CODE DATABASE
      numraw = `curl -sS "#{bigcouchurl}/numbers%2F%2B1#{formnum[0,3]}/%2B1#{formnum}"`
      #PARSE NUMBER DOCUMENT
      numparse = JSON.parse(numraw)
      if (numparse["pvt_assigned_to"] != nil)
        accountid = numparse["pvt_assigned_to"]
      else
        puts "Number not assigned to an account"
        exit
      end
    end

    accraw = `curl -sS "#{bigcouchurl}/accounts/#{accountid}"`
    accparse = JSON.parse(accraw)
    #LOAD INFO INTO HASH
    raccount["id"] = accparse["_id"]
    raccount["name"] = accparse["name"]
    raccount["role"] = accparse["role"]
    raccount["realm"] = accparse["realm"]
    #LOOP TO GET INFO OF EACH PARENT ACCOUNT
    for i in 0..accparse["pvt_tree"].length-1
      parentid = accparse["pvt_tree"][i]
      parentraw = `curl -sS "#{bigcouchurl}/accounts/#{parentid}"`
      parentparse = JSON.parse(parentraw)
      rparent["id#{i}"] = accparse["pvt_tree"][i]
      rparent["name#{i}"] = parentparse["name"]
      rparent["role#{i}"] = parentparse["role"]
      rparent["realm#{i}"] = parentparse["realm"]
    end

    #SUGARCRM INFO GET
    crm = SugarCRM.connect("http://crm.2600hz.com:32950/sugar", 'jeremy', 'aBkXX1R1wBnI')
    sugaraccount = crm::Account.find_by_name(accparse["name"])
    rsugar["description"] = sugaraccount.description
    rsugar["website"] = sugaraccount.website
    rsugar["services"] = sugaraccount.account_services_c
    contactcount = 0
    test = Hash.new
    sugaraccount.contacts.each do |contact|
      rsugarcontact["first_name#{contactcount}"] = ["#{contact.first_name}"]
      rsugarcontact["last_name#{contactcount}"] = ["#{contact.last_name}"]
      rsugarcontact["title#{contactcount}"] = ["#{contact.title}"]
      rsugarcontact["phone_work#{contactcount}"] = ["#{contact.phone_work}"]
      emailcount = 0
      contact.email_addresses.each do |email|
        rsugarcontact["email_address#{contactcount};#{emailcount}"] = ["#{email.email_address}"]
        emailcount = emailcount+1
      end
      contactcount = contactcount+1
    end

    puts rsugarcontact["email_address0;0"]
    #RETURN INFO
    p "###################"
    puts raccount
    p "###################"
    p rparent
    p "###################"
    p rsugar
    p "###################"
    p rsugarcontact
    p "###################"
    return raccount, rparent, rsugar, rsugarcontact

    end

end

end
