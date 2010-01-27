= SMSnger

Want to send an SMS from your Ruby application?  SMSnger allows you to do just that.  
It allows you to send a text-message in the form of an e-mail to a cell phone on any
of the supported carriers.

== Supported Carriers (US & International): 

Alltel, Ameritech, AT&T, Bell Atlantic, BellSouth Mobility, Beeline(UA), BlueSkyFrog, 
Boost Mobile, BPL Mobile, Cellular South, Claro (Brazil, Nicaragua), Comcast, Du, 
E-Plus, Etisalat, Fido, kajeet, Mobinil, Mobitel, Movistar, Metro PCS, O2, Orange, 
Powertel, PSC Wireless, Qwest, Rogers, Southern Link, Sprint, Suncom, 
T-Mobile (US/UK/Germany), Telefonica, Tracfone, Virgin Mobile, Verizon Wireless, 
Vodafone (UK, Egypt, Italy, Japan, Spain), and many more ...

== Opt-In Warning for Some International Carriers

Some International carriers require that their users subscribe to an Email to SMS
feature before they are able to receive SMS messages this way.  If one your users
mentions that they are not receiving their messages, chances are it is due to this
limitation.

Some carriers that need this include, Mobitel, Etisalat, T-Mobile (Netherlands), 
etc.

== Setup Instructions

To use SMSnger, first require the library:

    require 'smsnger'

Once the library is required, you need to run the setup like so:

    SMSnger.setup(:from => "someone@example.com")
    
By default sendmail is used, but you can use SMTP as follows:

    SMSnger.setup(
      :from => "someone@example.com",
      :mail_via => :smtp,
      :smtp => {
        :host     => 'smtp.yourserver.com',
        :port     => '25',
        :user     => 'user',
        :password => 'pass',
        :auth     => :plain,  # :plain, :login, :cram_md5, no auth by default
        :domain   => "example.com"
      }
    )

That's it!  Now you're good to go.

== Example Usage
	
* You have to send in the phone number, without any non-numeric characters.  The
  phone numbers must be 10 digits in length.  
* The two required parameters are the phone number and the phone carrier.
* Here are some of the default carrier values:
		
    Alltel Wireless   =>  "alltel"
    AT&T/Cingular     =>  "at&t"
    Boost Mobile      =>  "boost"
    Sprint Wireless   =>  "sprint"
    T-Mobile US       =>  "t-mobile"
    T-Mobile UK       =>  "t-mobile-uk"
    Virgin Mobile     =>  "virgin"
    Verizon Wireless  =>  "verizon"
    Vodafone Tokyo    =>  "vodafone-jp-tokyo"

* <b>Check lib/carriers.yml for a complete list of supported carriers, including international
  carriers as well.</b>

    SMSnger.deliver_sms("5558675309","at&t","message")

* If you want to set a custom from e-mail per SMS message, you can do so 
  by doing the following.

    SMSnger.deliver_sms("5558675309","at&t","message", :from => "bob@test.com")

* You can set the maximum length of the SMS message, which is not set by
  default.  Most phones can only accept 128 characters.  To do this just 
  specify the limit option.

    SMSnger.deliver_sms("5558675309","at&t","message", :limit => 128)

* You can retrieve just the formatted address to use in your own mailer.

    SMSnger.get_sms_address("5558675309","at&t") # => "5558675309@txt.att.net"

== Special Thanks

A big thank you to Brendan G. Lim, the original author of SMS Fu, who inspired the creation 
of this gem and who did most of the heavy-lifting.

Copyright (c) 2010 Joel Watson, released under the MIT license

(Large) Portions Copyright (c) 2008 Brendan G. Lim, Intridea, Inc., released under the MIT license
