// https://mister-devel.github.io/MkDocs_MiSTer/developer/emu/#user-port-extra-usb-31a-style-connector-on-mister
// https://github.com/alanswx/Tutorials_MiSTer

// assign = affectation continue pour câbler en dehors d'une instruction always.

// Uniquement dans un block inital ou always :

// <= non bloquant et est effectué sur chaque front positif de l'horloge.
// = affectation bloquante, à l'intérieur des instructions always applique l'ordre séquentiel.

// Nombre [taille]'[base][valeur], exemple: 3'b010 (3 bits)
// integer a = 5423 -> integer donc 32 bits, avec une valeur décimale
// Negatif exemple : -6'd3
// Chaine de caractere : reg [8*11:1] str = "Hello World";
// tableau de 15 octets : reg [7:0] tableau [3:0]

// USER_IN | USB Name  | SMS      | USB3 
// --------+-----------+----------+------					DSR	5-o
//     0   | D+/RX     | Bas      | 3										o-1		VSS	(Masse)
//     1   | D-/TX     | Haut     | 2						DTR	6-o
//     2   | TX-/RTS   | Bouton 1 | 8										o-2		RX
//     3   | GND_d/CTS | Droite   | 7						CTS	7-o
//     4   | RX+/DTR   |          | 6										o-3		TX
//     5   | RX-/DSR   | Gauche   | 5						RTS	8-o
//     6   | TX+/IO6   | Bouton 2 | 9										o-4		VDD	5v
//         | 5v        |          | 1				3.3 / IO6	9-o
//         | GND       |          | 4
// --------------------------------------

module toto 
(
	input			horloge,
	input			[1:0] boutons,							// boutons[1]: bouton utilisateur, boutons[0]: bouton affichage menu.
	input			[6:0] port_utilisateur_entree,	// Mettre USER_OUT à 1 pour lire depuis USER_IN.
	input			[31:0] joystick_usb,
	output		led_utilisateur,
	output		[1:0] led_tension,
	output		[1:0] led_disque,
	output reg	[15:0] addr,
   output reg	[23:0] dout,
	output reg	writeEnable,
	input			[10:0] clavier
);

reg [31:0] compteur;
reg LED_CLIGNOTANTE;

reg ps2_changed;
reg ps2_released;
reg old_state;
reg [7:0] hack_scancode; // output

initial
begin
	LED_CLIGNOTANTE = 1'b0;
	compteur = 32'b0;
end

always@(posedge(horloge))
begin
	if(compteur<2500000)
		compteur <= compteur + 1'b1;
	else
	begin
		LED_CLIGNOTANTE <= !LED_CLIGNOTANTE;
		compteur <= 32'b0;
	end
	
	if ( addr == 0 )
	begin
		dout <= 24'b111111111111111111111111;
		addr <= 16'( addr + 1 );
	end
	else
	begin
		if ( addr < (320*200) )
		begin
			writeEnable <= 1'b1;
			if ( addr < (320*200)/2 )
				dout <= 24'b000000001111111100000000;
			else
				dout <= 24'b111111110000000000000000;
			addr <= 16'( addr + 1 );
		end
	end

end

always@(posedge(horloge))
begin
	old_state <= clavier[10];
	ps2_changed <= (old_state != clavier[10]);
	ps2_released <= ~clavier[9];
	
	if (ps2_changed)
	begin
		casez (clavier[8:0])
			9'h?16: hack_scancode <= "1";  // 1
			9'h?1E: hack_scancode <= "2";  // 2
			9'h?26: hack_scancode <= "3";  // 3
			9'h?25: hack_scancode <= "4";  // 4
			9'h?2E: hack_scancode <= "5";  // 5
			9'h?36: hack_scancode <= "6";  // 6
			9'h?3D: hack_scancode <= "7";  // 7
			9'h?3E: hack_scancode <= "8";  // 8
			9'h?46: hack_scancode <= "9";  // 9
			9'h?45: hack_scancode <= "0";  // 0
			
			9'h?1C: hack_scancode <= "A";  // a
			9'h?32: hack_scancode <= "B";  // b
			9'h?21: hack_scancode <= "C";  // c
			9'h?23: hack_scancode <= "D";  // d
			9'h?24: hack_scancode <= "E";  // e
			9'h?2B: hack_scancode <= "F";  // f
			9'h?34: hack_scancode <= "G";  // g
			9'h?33: hack_scancode <= "H";  // h
			9'h?43: hack_scancode <= "I";  // i
			9'h?3B: hack_scancode <= "J";  // j
			9'h?42: hack_scancode <= "K";  // k
			9'h?4B: hack_scancode <= "L";  // l
			9'h?3A: hack_scancode <= "M";  // m
			9'h?31: hack_scancode <= "N";  // n
			9'h?44: hack_scancode <= "O";  // o
			9'h?4D: hack_scancode <= "P";  // p
			9'h?15: hack_scancode <= "Q";  // q
			9'h?2D: hack_scancode <= "R";  // r
			9'h?1B: hack_scancode <= "S";  // s
			9'h?2C: hack_scancode <= "T";  // t
			9'h?3C: hack_scancode <= "U";  // u
			9'h?2A: hack_scancode <= "V";  // v
			9'h?1D: hack_scancode <= "W";  // w
			9'h?22: hack_scancode <= "?";  // ?
			9'h?35: hack_scancode <= "Y";  // y
			9'h?1A: hack_scancode <= "Z";  // z
			
			9'h?29: hack_scancode <= " ";  // space
			9'h?52: hack_scancode <= "'";  // quotation mark
			9'h?41: hack_scancode <= ",";  // comma
			9'h?4C: hack_scancode <= ";";  // semicolon
			9'h?49: hack_scancode <= ".";  // period
			9'h?4A: hack_scancode <= "/";  // slash
			9'h?54: hack_scancode <= "[";  // left square bracket
			9'h?5B: hack_scancode <= "]";  // right square bracket
			9'h?5D: hack_scancode <= 8'd92;  // backslash
			9'h?4E: hack_scancode <= "-";  // dash
			
			9'h?5A: hack_scancode <= 8'd128;  // enter
			9'h?66: hack_scancode <= 8'd129;  // backspace
			9'h?76: hack_scancode <= 8'd140;  // escape
			9'h?05: hack_scancode <= 8'd141;  // F1
			9'h?06: hack_scancode <= 8'd142;  // F2
			9'h?04: hack_scancode <= 8'd143;  // F3
			9'h?0C: hack_scancode <= 8'd144;  // F4
			9'h?03: hack_scancode <= 8'd145;  // F5
			9'h?0B: hack_scancode <= 8'd146;  // F6
			9'h?83: hack_scancode <= 8'd147;  // F7
			9'h?0A: hack_scancode <= 8'd148;  // F8
			9'h?01: hack_scancode <= 8'd149;  // F9
			9'h?09: hack_scancode <= 8'd150;  // F10
			9'h?78: hack_scancode <= 8'd151;  // F11
			9'h?07: hack_scancode <= 8'd152;  // F12
			
			9'h?6B: hack_scancode <= 8'd130;  // left arrow
			9'h?75: hack_scancode <= 8'd131;  // up arrow
			9'h?74: hack_scancode <= 8'd132;  // right arrow
			9'h?72: hack_scancode <= 8'd133;  // down arrow
			
			9'h?79:  hack_scancode <= "+";  // +
			9'h?7B:  hack_scancode <= "-";  // -
			9'h?7C:  hack_scancode <= "*";  // *
			9'h?55:  hack_scancode <= "=";  // =
		default: hack_scancode <= 8'd0;
		endcase
	end
	else if (ps2_released) hack_scancode <= 8'd0;
	else hack_scancode <= hack_scancode;
end

assign led_utilisateur = LED_CLIGNOTANTE;
assign led_tension = 0;
assign led_disque = !port_utilisateur_entree[2] | joystick_usb[4] | boutons[1];

endmodule
