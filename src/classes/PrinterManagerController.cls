public class PrinterManagerController{

    public String selectedPrinter { get; set; }
    
    public String selectedCommand { get; set; }
    
    public String selectedCommandLabel { get; set; }
    
    public String selectedFile { get; set; }
    
    public Id lastMessageId { get; set; }
    
    public String lastResponse { get; set; }
    
    public List<SelectOption> getPrinters() {
        List<Printer__c> printers = [Select Id, Name From Printer__c Order By Name ASC];
        List<SelectOption> ret = new List<SelectOption>();
        for (Printer__c currentPrinter : printers) {
            SelectOption current = new SelectOption(currentPrinter.name, currentPrinter.name);
            ret.add(current);
        }
        return ret;
    }
    
    public PageReference selectPrinter() {
        return Page.PrinterCommandManager;
    }
    
    public List<SelectOption> getCommands() {
        List<Printer_Command__c> commands = [Select Id, Label__c From Printer_Command__c Order By Sort__c ASC];
		List<SelectOption> ret = new List<SelectOption>();
        for (Printer_Command__c currentCommand : commands) {
            ret.add(new SelectOption(currentCommand.Id, currentCommand.Label__c));
        }
        return ret;
    }
    
    public PageReference selectCommand() {
        //insert the message
        Printer_Command__c command = [Select Id, Label__c, Message__c, Body__c From Printer_Command__c Where Id = :selectedCommand];
        
        selectedCommandLabel = command.Label__c;
        Printer_Message__c message = new Printer_Message__c();
        message.Printer_Name__c = selectedPrinter;
        message.Message__c = command.Message__c;
        message.Body__c = command.Body__c;
        message.Printer_Command__c = selectedCommand;

        insert message;
        lastMessageId = message.Id;
        
        return Page.PrinterCommandResults;
    }
    
    public void checkResponse() {
        Printer_Message__c message = [Select Id, Printer_Command__c, Printer_Command__r.Render_As__c, Response__c From Printer_Message__c Where Id = :lastMessageId];
        
        Map<String, Object> parsedResponse = 
           (Map<String, Object>)
              JSON.deserializeUntyped(message.Response__c);        
        
        if (message.Printer_Command__r.Render_As__c == 'raw') {
			lastResponse = message.Response__c;
        } else if (message.Printer_Command__r.Render_As__c == 'Simple') {
            lastResponse = '<h2 class="bg-primary">' + 
                (String) parsedResponse.get('result') + '<h2>';
        } else if (message.Printer_Command__r.Render_As__c == 'Temp') {
			Map<String, Object> tool0 = (Map<String, Object>) parsedResponse.get('tool0');
            lastResponse = '<h2 class="bg-primary">Target: ' + 
                 String.valueOf(tool0.get('target')) + ', Actual: ' +
                 String.valueOf(tool0.get('actual')) + '<h2>';
            
        } else {
            lastResponse = message.Response__c;
        }
    }
    
    public PageReference newCommand() {
        selectedCommand = null;
        selectedFile = null;
        lastMessageId = null;
        lastResponse = null;
        
        return Page.PrinterCommandManager;
    }
    
    public PageReference startOver() {
        selectedPrinter = null;
        selectedCommand = null;
        selectedFile = null;
        lastMessageId = null;
        lastResponse = null;
        
        return Page.PrinterManager;
    }
    
}