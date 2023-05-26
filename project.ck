class DefaultNote extends Event {
    float duration;
    int baseNote;

    float gain;
    SinOsc s;
    
    fun void setting(){}
    fun void play(){
        
    }
    fun void menu(){}
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
        input(1) => string choice;
        if (choice == "1") {
            1 => ready; 
        }
        else if (choice == "2") {
            0 => ready;
        }
        else {
            chooseFile();
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
fun string input(int mode){
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
                    // ascii 0 is 48
                    return iCastoStr(msg.ascii);     
                }   
            }
        }
       0.2::second => now; 
    }
}

fun string showMenu(){
    chout <= IO.newline();
    chout <= "Select a mode:" <= IO.newline();
    chout <= "1) custom midi note" <= IO.newline();
    chout <= "2) default stk" <= IO.newline();
    chout <= "3) self define melody" <= IO.newline();
    return input(1);
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

SelfMelody sm;
DefaultNote dn;
spork ~playMusic(sm);
spork ~playMusic(dn);


while(1) {

    showMenu() => string choice;
    if (choice == "3") {
        sm.menu();
    }

    sm.signal();
    1::second => now;   
}