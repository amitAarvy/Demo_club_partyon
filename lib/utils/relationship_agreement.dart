
String agreement({required String clubName,required String clubAdress,required int date, required int month,required int year}) {
 String monthName = month == 1 ? "January" : month == 2 ? "February" : month ==
     3 ? "March" : month == 4 ? "April" : month == 5 ? "May" : month == 6
     ? "June"
     : month == 7 ? "July" : month == 8 ? "August" : month == 9
     ? "September"
     : month == 10 ? "October" : month == 11 ? "November" : month == 12
     ? "December"
     :"";
 return """
                                                              RELATIONSHIP AGREEMENT

THIS RELATIONSHIP AGREEMENT (HEREINAFTER REFERRED TO AS "THE AGREEMENT") IS MADE AND ENTERED INTO AS ON THE ${date < 10 ? ('$date ST') : ('$date TH')} DAY OF $monthName, $year ("THE EFFECTIVE DATE")
BY AND BETWEEN

"PARTYON ENTERTAINMENT PRIVATE LIMITED" is a private limited Company, registered under the Companies Act, 2013 and having its registered office address at BG1/25, Paschim Vihar, New Delhi 110063
Hereinafter referred to as the "Service Provider"
                                                                                               ----- PARTY OF THE FIRST PART
AND
$clubName is a business organisation, and whose principal place of business is located at $clubAdress
(Hereinafter referred to as the "Client"
----- PARTY OF THE SECOND PART

Hereinafter PartyOn Entertainment Private Limited and the $clubName shall individually be referred to as a "Party" and collectively referred to as the "Parties", wherever the context so permits. 
NOW, THEREFORE, IN CONSIDERATION OF THE MUTUAL OBLIGATIONS HEREIN CONTAINED, TERMS AND CONDITIONS HEREINAFTER SET FORTH, THE PARTIES MUTUALLY AGREE AS FOLLOWS:
1.SCOPE OF THE AGREEMENT/SERVICES:
This Agreement shall be deemed to have come into effect on the Effective Date and shall, subject to the earlier termination by Service Provider only in accordance with the provisions mentioned below,  for a period of Three (3) years ("Initial Term"). Upon the expiration of the Initial Term, this Agreement shall automatically renew for additional successive period of Three (3) years unless either Party gives written notice to the other Party not less than Ninety (90) days prior to the end of the current Initial Term of its intent not to renew this Agreement at the end of such Initial Term.

2.MANAGEMENT OF PORTAL:
a.The Service Provider and Client agreed that it is the responsibility of the Client to operate portal provided by the Service Provider on a regular basis to update all the events or performances scheduled in the upcoming months.
b.The Service Provider and Client agreed that it is the duty of the Client to turn on all the devices all the time and take due care to avail the facility of live streaming whenever there will be any event / party.
c.The Service Provider and Client also agreed that, if Client do not keep the live streaming on during the events, it will heavily impact the market presence of the client on the service providers Platform.

3.ADVERTISEMENT REVENUE:

The Service Provider and Client that Service provider is entitle to bring Third Party advertisers for the client in order to generate extra income through digital platform for the client and it is also agreed that upon reaching a live viewership more than 50,000, if any revenue earned through the same shall be shared between the party of the first part (i.e. Service Provider) and party of the second part (i.e. Client) vide ration 80:20.
 
4.NO ADDITIONAL CHARGES:

The Service Provider and Client agreed that the client is prohibited to charge any additional or excessive amount to the Customers through Platform as compared to the amount of direct booking by the Client without platform. 


 """;
}

const agreementPart2=
"""
5.PAYMENT AND CONSIDERATION:
a)The Service Provider and Client agreed to charge any applicable taxes over and above the 6% commission charged by Service Provider .
b) Service Provider shall release all the amount/payments collected by it on account of booking through the App/Platform for the Client on the date or within 7 working days time net of Commission Fee and Deployment Commission.
c)Upon Completion of the Event, the Client shall raise an invoice on the service provider 
d)Service Provider shall install all the required Hardware at the clubs, resorts, cafés of Client at his own cost. 

6.CANCELLATION OF BOOKING:
1)If booking is cancelled any time within 30 minutes of start of the event, Service Provider is not liable to pay any amount to the Client and reserved entry and table of cancelled booking will be open for further bookings.
2)If booking is cancelled any time after 30 minutes of start of the event, the service provider is liable to pay to the Client within the time specified herein above.

7.BREAKDOWN OF APP/PLATFORM:
Any delay or failure in the performance by Service Provider under this Agreement shall be excused and shall be without liability if and to the extent caused by a technical or other failure of any of the Platforms for reasons that are beyond the reasonable anticipation or control of Service Provider, despite Service Providers reasonable efforts to prevent, avoid, delay or mitigate the effect of such occurrence.

8.TERMINATION:

1.This Agreement may be terminated:
a.by either Party at any time after the completion of "Initial Term" (i.e. 3 Years) from the Effective Date upon not less than ninety (90) days written notice to the other Party.
b.By the Service Provider at its sole discretion due to breach of any material terms and conditions of this agreement by the Client. Service Provider at its sole discretion may or may not terminate the agreement but reserves the right to withdraw the option of booking of that particular Client from his platform. 
             2.  In no case the Relationship Agreement be terminated by the Client on or before completion of 3 years from the date of execution of this agreement mentioned hereinabove.

9.LIMITATION OF LIABILITY OF CLIENT:
In no case Client is allowed to engage with any of the competitors of service provider directly or indirectly through relatives or friends or in any other manner.

10.NON-COMPETE CLAUSE: 
The party of the first part and party of the second part agreed that it is the responsibility of the Client that not to associate with any other organisation and/or company providing similar services and/or directly or indirectly competitor of Service Provider until the completion 3 years from the date of termination of this agreement.
11.GOVERNING LAW:
This agreement, the rights and obligations of the parties hereunder and all claims or otherwise, shall be governed by and construed and enforced in accordance with the laws of India and the laws of Union Territory of Delhi, and the exclusive venue of any such action shall be placed in the state or district courts or Tribunals of New Delhi, Delhi. 

FOR PARTYON ENTERTAINMENT 
PRIVATE LIMITED					 ________________________:

Sign: ___________________				Sign: ___________________

Name: ________________				Name: ________________

Designation: _________________			Designation: ________________
    """;