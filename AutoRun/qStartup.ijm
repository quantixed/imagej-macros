macro "AutoRun" { 
       path = getDirectory("plugins")+"quantixed/Figure Maker/qFunctions.txt"; 
       functions = File.openAsString(path); 
       call("ij.macro.Interpreter.setAdditionalFunctions", functions); 
   }