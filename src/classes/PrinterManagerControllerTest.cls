@istest
public class PrinterManagerControllerTest{

    static testmethod void testSimple() {
        //setup
        Printer__c printer = new Printer__c();
        printer.Name = 'PrinterA';
        insert printer;
        
        Printer_Command__c commandTemplate = new Printer_Command__c();
        commandTemplate.Label__c = 'TestMe';
        commandTemplate.Message__c = '/one/two';
        commandTemplate.Body__c = '{ do this }';
        commandTemplate.Render_As__c = 'Simple';
        insert commandTemplate;
        
        //test
        PrinterManagerController controller = new PrinterManagerController();
        
        //printers
        List<SelectOption> printers = controller.getPrinters();
        System.assertEquals(1, printers.size(), 'Printer size is wrong');
        
        controller.selectedPrinter = ((SelectOption)printers.get(0)).getLabel();
        PageReference pr1 = controller.selectPrinter();
        
        System.assert(pr1 != null);
        
        //commands
        List<SelectOption> commands = controller.getCommands();
        System.assertEquals(1, commands.size(), 'Commands size is wrong');
        
        controller.selectedCommand = ((SelectOption)commands.get(0)).getValue();
        controller.selectedCommandLabel = ((SelectOption)commands.get(0)).getLabel();
        
        PageReference pr2 = controller.selectCommand();
        System.assert(pr2 != null);
        
        //check the message
        Printer_Message__c message = [Select id, name, Printer_Name__c, Printer_Command__c, Message__c, Body__c From Printer_Message__c];
		System.assert(message != null);
        System.assertEquals(printer.name, message.Printer_Name__c);
        System.assertEquals(commandTemplate.Body__c, message.Body__c);
        System.assertEquals(commandTemplate.Message__c, message.Message__c);
		System.assertEquals(commandTemplate.Id, message.Printer_Command__c);
        System.assertEquals(message.id, controller.lastMessageId);
        
        //Update the response
        Printer_Message__c messageUpdate = new Printer_Message__c();
        messageUpdate.Id = message.id;
        messageUpdate.Response__c = '{ "result" : "OK" }';
        update messageUpdate;
        
        controller.checkResponse();
        System.assert(controller.lastResponse.contains('OK'));
        
        //update to test raw
        commandTemplate.Render_As__c = 'Raw';
        update commandTemplate;
        
        controller.checkResponse();
        System.assertEquals(controller.lastResponse, messageUpdate.Response__c);
        
        //update to temp
        commandTemplate.Render_As__c = 'Temp';
        update commandTemplate;
        
        messageUpdate.Response__c = ' { "tool0" : { "target": "100.0", "actual" : "50.0"} } ';        
        update messageUpdate;
        
        controller.checkResponse();
        System.assert(controller.lastResponse.contains('100.0'));
        
        PageReference pr3 = controller.newCommand();
        System.assert(pr2 != null);
        System.assert(controller.selectedCommand == null);
        System.assert(controller.selectedPrinter != null);
        
        PageReference pr4 = controller.startOver();
        System.assert(pr4 != null);
        System.assert(controller.selectedPrinter == null);
        

    }
    
}