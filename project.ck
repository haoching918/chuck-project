class DefaultNote extends Event {
    50::ms => dur duration;
    60 => int curNote;
    0.05 => float gain;
    SinOsc s;
    
    fun void setting(){}
    
    fun int which2note(int input){
        if(input >= 30 && input <= 40){
            30 -=> input;
            [0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17] @=> int notes[];
            return notes[input];
        }
        else if(input >= 17 && input <= 25){
            17 -=> input;
            [1, 3, -1, 6, 8, 10, -1, 13, 15] @=> int notes[];
            return notes[input];
        }
        else{
            return -1;
        }

    }
    
    fun void play(){
        Hid kb;
        HidMsg msg;

        // // hook device with device num
        0 => int device;
        // //detect if keyboard is hooked
        if (kb.openKeyboard(device) == false)  me.exit();
        // <<<"keyboard", kb.name(), "is ready!">>>;awseedf
        
        while(true){
            this.gain => s.gain;
            kb => now;
            while(kb.recv(msg)) {
                if (msg.isButtonDown()){
                    this.which2note(msg.which) => int scale;
                    s =< dac;
                    s => dac;
                    if (scale == -1) {
                        s =< dac;
                        continue;
                    }
                    Std.mtof( scale + this.curNote ) => float freq;
                    if( freq > 20000 ){
                        s =< dac;
                        continue;
                    }
                    freq => s.freq;
                    
                    this.duration => now;
                }
                else{
                    s =< dac;
                }
                
            }
        }
    }
    fun void menu(){
        chout <= IO.newline() <= "   press ESC to leave  " <= IO.newline();
        chout <= " ______________________" <= IO.newline();
        chout <= "||W|E|||T|Y|U|||O|P | |" <= IO.newline();
        chout <= "||_|_|||_|_|_|||_|_|| |" <= IO.newline();
        chout <= "|A|S|D|F|G|H|J|K|L|:|\"|" <= IO.newline();
        chout <= "|_|_|_|_|_|_|_|_|_|_|_|" <= IO.newline();
        chout <= IO.newline() <= "   <- Volume ->  " <= IO.newline();
        chout <= IO.newline() <= "   v   Tone   ^  " <= IO.newline();
        
        while(true){
            input(3) => string option;
            if(option == "esc"){
                break;
            }
            else if(option == "rise"){
                if(this.curNote < 108){
                    12 +=> this.curNote;
                    chout <= "rise the tone" <= IO.newline();
                }
            }
            else if(option == "fall"){
                if(this.curNote > 24){
                    12 -=> this.curNote;
                    chout <= "fall the tone" <= IO.newline();
                }
            }
            else if(option == "increase"){
                if(this.gain < 1){
                    0.01 +=> this.gain;
                    chout <= "increse the volume" <= IO.newline();
                }
            }
            else if(option == "decrease"){
                if (this.gain > 0.01){
                    0.01 -=> this.gain;
                    chout <= "decrese the volume" <= IO.newline();
                }
            }
        }
    }
}
class ModalBar_ extends Event {
    0.5::second => dur duration;
    ModalBar inst => dac;
    HidMsg choice;
    Hid keyboard;
    0 => int tmp;
    
    fun void menu(){
        chout <= IO.newline();
        chout <= "esc to leave" <= IO.newline();
        chout <= "z) Marimba" <= IO.newline();
        chout <= "x) Vibraphone" <= IO.newline();
        chout <= "c) Agogo" <= IO.newline();
        chout <= "v) Wood1" <= IO.newline();
        chout <= "b) Reso" <= IO.newline();
        chout <= "n) Wood2" <= IO.newline();
        chout <= "m) Beats" <= IO.newline();
        chout <= ",) Two Fixed" <= IO.newline();
        chout <= ".) Clump" <= IO.newline();
        
        while (true){
            input_modalbar(1) => tmp;
            if (tmp == -1) {
                break;
            }
            this.play();
        }
    }

    fun void play() {
        //<<<input_modalbar(1)>>>;
        inst => dac;
        0.5 => inst.modeGain;
        1 => inst.strike;
        tmp => inst.preset;
        0.5 => inst.strikePosition;
        Std.mtof(50) => inst.freq;
        duration => now;
    }

}

fun int input_modalbar(int mode){
    Hid kb;
    HidMsg msg;
    // // hook device with device num
    0 => int device;
    // //detect if keyboard is hooked
    if (kb.openKeyboard(device) == false)  me.exit();
    // <<<"keyboard", kb.name(), "is ready!">>>;
    while(true){
        kb => now;
        // mode 1 for selection 
        if (mode == 1) {
            while(kb.recv(msg)){
                if (msg.isButtonDown()){
                    if (msg.which == 1) {
                        return -1;
                    }
                    else {
                        return msg.which - 44;     
                    }
                }
            }
        }
        0.2::second => now; 
    }
}
class SelfMelody extends Event {
    5::second => dur duration;
    0 => int pos;
    0.5 => float gain;
    1 => int rate;
    0 => int ready;
    string filePath;
    SndBuf my_player;

    fun void menu() {
        chout <= IO.newline();
        chout <= "1) Start" <= IO.newline();
        chout <= "2) Stop" <= IO.newline();
        chout <= "3) Choose File" <= IO.newline();
        chout <= "4) Setting" <= IO.newline();
        input(1) => string choice;
        if (choice == "1") {
            1 => ready; 
        }
        else if (choice == "2") {
            0 => ready;
        }
        else if (choice == "3") {
            chooseFile();
        }
        else if (choice == "4"){
            chout <= IO.newline() <= "   <- Volume ->  " <= IO.newline();
            chout <= IO.newline() <= "   v   Rate   ^  " <= IO.newline();
            while (1) {
                chout <= "Volume : " <= gain <= IO.newline();
                chout <= "Rate : " <= rate <= IO.newline();
                input(3) => string option;
                if (option == "rise") {
                    1 +=> rate;
                }
                else if (option == "fall") {
                    1 -=> rate;
                }
                else if (option == "increase") {
                    0.1 +=> gain;
                }
                else if (option == "decrease") {
                    0.1 -=> gain;
                }
                else break;
            }
        }
    }
    fun void chooseFile() {
        FileIO fio;
        fio.open( me.dir() + "sound/sound.txt" , FileIO.READ );
        // ensure it's ok
        if( !fio.good() )
        {
            cherr <= "can't open file" <= IO.nl();
            me.exit();
        }
        // variable to read into
        string str;
        string fileNames[10];
        0 => int cnt;

        chout <= IO.newline(); 
        chout <= "choose a file:" <= IO.newline(); 
        while( fio => str )
        {
            str => fileNames[cnt++];
            chout <= cnt <= ") " <= str <= IO.newline();
        }
        
        Std.atoi(input(1))-1=> int choice;
        
        chout <= fileNames[choice]<=IO.newline();
        me.dir() + "sound/" + fileNames[choice] => filePath;
        chout <= "file set to " + fileNames[choice] <= IO.newline(); 
    }
    fun void play() {
        if (ready == 0) return;
        my_player => dac;
        filePath => my_player.read;
        gain => my_player.gain;
        rate => my_player.rate;
        pos => my_player.pos;
        duration => now;
    }
}

fun string iCastoStr(int input) {
    48 -=> input;
    ["0","1","2","3","4","5","6","7","8","9"] @=> string num[];
    return num[input];
}
fun string which2note(int input){
    if(input >= 30 && input <= 40){
        30 -=> input;
        ["0", "2", "4", "5", "7", "9", "11", "12", "14", "16", "17"] @=> string notes[];
        return notes[input];
    }
    else if(input >= 17 && input <= 25){
        17 -=> input;
        ["1", "3", "-1", "6", "8", "10", "-1", "13", "15"] @=> string notes[];
        return notes[input];
    }
    else{
        return "-1";
    }

}
fun string input(int mode){
    Hid kb;
    HidMsg msg;

    // // hook device with device num
    0 => int device;
    // //detect if keyboard is hooked
    if (kb.openKeyboard(device) == false)  me.exit();
    // <<<"keyboard", kb.name(), "is ready!">>>;awseedf

    while(true){
        kb => now;
        // mode 1 for selection 
        if (mode == 1) {
            while(kb.recv(msg)){
                if (msg.isButtonDown()){
                    // ascii 0 is 48
                    return iCastoStr(msg.ascii);     
                }   
            }
        }
        else if (mode == 2){
            while(kb.recv(msg)){
                if (msg.isButtonDown()){
                    return which2note(msg.which);     
                }   
            }
        }
        else if(mode == 3){
            while(kb.recv(msg)){
                if (msg.isButtonDown()){
                    if(msg.which == 1){
                        return "esc";
                    }
                    else if(msg.which == 200){
                        return "rise";
                    }
                    else if(msg.which == 208){
                        return "fall";
                    }
                    else if(msg.which == 205){
                        return "increase";
                    }
                    else if(msg.which == 203){
                        return "decrease";
                    }
                    else{
                        return "other";
                    }
                }   
            }
        }
        else if(mode == 4){
            if (msg.isButtonUp()){
                return "esc";
            }
            else{
                return "other";
            }
        }
        0.2::second => now; 
    }
}

fun string showMenu() {
    chout <= IO.newline();
    chout <= "Select a mode:" <= IO.newline();
    chout <= "1) custom midi note" <= IO.newline();
    chout <= "2) modal bar" <= IO.newline();
    chout <= "3) self define melody" <= IO.newline();
    chout <= "4) start recording"<= IO.newline();
    chout <= "5) stop recording"<= IO.newline();
    return input(1);
}

class Machine_ {
    me.dir() + "rec.ck" => string filePath;
    int ID;
    fun void startRecord() {
        Machine.add(filePath) => ID;
    }
    fun void stopRecord() {
        Machine.remove(ID);
    }
}

fun void playMusic(SelfMelody sm){
    while (1) {
        sm => now;
        sm.play();
    }
}
fun void playMusic(DefaultNote dn){
    while (1) {
        dn => now;
        dn.play();
    }
}
fun void playMusic(ModalBar_ md){
    while (1) {
        md => now;
        md.play();
    }
}
Machine_ myMachine;
SelfMelody sm;
DefaultNote dn;
ModalBar_ md;
spork ~playMusic(sm);
spork ~playMusic(dn);
spork ~playMusic(md);

while(1) {

    showMenu() => string choice;
    if(choice == "1") {
        dn.signal();
        dn.menu();
    }
    else if (choice == "2") {
        md.menu();
        md.signal();
    }
    else if (choice == "3") {
        sm.menu();
    }
    else if (choice == "4") {
        chout <= "Start recording" <= IO.newline();
        myMachine.startRecord();
    }
    else if (choice == "5") {
        chout <= "Stop recording" <= IO.newline();
        myMachine.stopRecord();
    }

    sm.signal();
    1::second => now;   
}