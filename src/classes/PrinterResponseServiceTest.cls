@isTest
public class PrinterResponseServiceTest{
    static testmethod void testSimple() {
        Printer_Message__c testMessage = new Printer_Message__c();
        testMessage.Printer_Name__c = 'AAA';
        testMessage.Message__c = '/api/onetwothree';
        testMessage.Body__c = 'nothing';
        insert testMessage;
        
        String result = PrinterResponseService.handleResponse(testMessage.id, 'OK');
        Printer_Message__c updatedMessage = [Select Id, Response__c from Printer_Message__c Where Id = :testMessage.id];
        system.assertEquals('OK', updatedMessage.Response__c);
    }
}