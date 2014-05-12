@RestResource(urlmapping='/PrinterResponse/*')
global with sharing class PrinterResponseService{
    @HttpPost
    global static string handleResponse(String originalId, String responseJson) {
		Printer_Message__c message = [Select Id, Name, Response__c From Printer_Message__c where Id = :originalId];
        message.Response__c = responseJson;
        update message;
        return 'OK';
    }
}