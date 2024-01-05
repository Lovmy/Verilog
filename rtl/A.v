
module mycore
(
	input			clk,
	input			reset,
	
	input			pal,
	input			scandouble,

	output reg	ce_pix,

	output reg	HBlank,
	output reg	HSync,
	output reg	VBlank,
	output reg	VSync,

	output reg	[7:0] rouge,
	output reg	[7:0] vert,
	output reg	[7:0] bleu,
	
	output	[15:0] addr,
   input		[23:0] din
);

reg   [9:0] x = 0;
reg   [9:0] y = 0;

reg   [9:0] decalage_x = 100;
reg   [9:0] decalage_y = 20;
reg   [9:0] largeur_x = 320;
reg   [9:0] hauteur_y = 200;

assign decalage_y = 10'( pal ? 50 : 20 );
assign addr = 16'( ( (y - decalage_y) * 10'd320 + (x - decalage_x) ) + 1 );

// Pour assurer le confort visuel, par exemple pour la norme de télévision analogique à 625 lignes, l'écran est éclairé 50 fois
// par seconde ; toutefois, pour des raisons d'économie en télédiffusion, le signal ne produit que 50 trames par seconde, une
// trame étant constituée par 312 lignes de rang pair ou impair. Dans ce cas, au mode progressif, la fréquence du balayage vidéo
// aurait dû être doublée et passer de 15,625kHz à 31,25kHz.

// 31250/50=625

// !a means "a is not 0"
// ~a means "invert the bits of a"

always @(posedge clk)
begin
	if(scandouble)							// -> forced_scandoubler=0 du fichier mister.ini
		ce_pix <= 1;						// Horloge video correct
	else
		ce_pix <= ~ce_pix;				// Inverse les bits de ce_pix, ce_pix a un une fois sur deux ?

	if(reset)
	begin
		x <= 0;								// Position du faisceau
		y <= 0;
	end
	else
	begin
		if ( ce_pix )
		begin
			if ( x == 637 )
			begin
				x <= 0;
				// Resolution television cathodique 720×576.
				// pal  : 625 lignes mais on ne voit que 768 × 576 lignes (le 576i).
				// ntsc : 525 lignes mais on ne voit sur 460 x 480 lignes (le 480i).
				// scanline : lignes impaires noires.
				if( y == ( pal ? ( scandouble ? 623 : 311 ) : ( scandouble ? 523 : 261 ) ) )	// Si bas de l'écran
				begin
					y <= 0;
				end
				else
				begin
					y <= y + 1'd1;		// On increment y
				end
			end
			else
			begin
				x <= x + 1'd1;			// On increment x jusqu'a qu'il atteigne le 637ieme pixel d'une ligne
			end
			
			// 16 millions de couleurs
			if ( x >= decalage_x && x < decalage_x+largeur_x && y >= decalage_y && y < decalage_y+hauteur_y )
			begin
				{ rouge, vert, bleu } <= { din[23:16], din[15:8], din[7:0] };
			end
			else	// bordure
			begin
				rouge <= 8'b00000000;
				vert  <= 8'b00000000;
				bleu  <= 8'b11111111;
			end

		end
	end
end

// Les signaux de synchronisation font partie des intervalles de "blanking".
// x			0 ------------------- 529 --- 544 --- 590
// HBlank	                       *****************
// HSync		                               *********

always @(posedge clk)
begin

	if (x == 529)										// HBlank = 1 entre le 529ieme et le 637ieme pixel d'une ligne
		HBlank <= 1;									// Durée pendant que le faisceau va de la fin d'une ligne au début de la suivante
	else
	begin
		if (x == 0)
			HBlank <= 0;
	end

	if (x == 544)										// Quand on arrive sur le 544ieme point d'une ligne (entre 529 et 637)
	begin
		HSync <= 1;										// Nouvelle ligne

		if (pal)
		begin
			if(y == (scandouble ? 609 : 304))	// VBlank entre 601 et 623, VSync entre 609 et 617
				VSync <= 1;								// Nouvelle image
			else
			begin
				if (y == (scandouble ? 617 : 308))
					VSync <= 0;
			end

			if(y == (scandouble ? 601 : 300))
				VBlank <= 1;							// Durée pendant que le faisceau va de la fin d'une image (bas-droite) au début (haut-gauche)
			else
			begin
				if (y == 0)
					VBlank <= 0;
			end
		end
		else	// NTSC
		begin
			if(y == (scandouble ? 490 : 245))
				VSync <= 1;
			else
			begin
				if (y == (scandouble ? 496 : 248))
					VSync <= 0;
			end

			if(y == (scandouble ? 480 : 240))
				VBlank <= 1;
			else
			begin
				if (y == 0)
					VBlank <= 0;
			end
		end
	end
	
	if (x == 590)
		HSync <= 0;
end

endmodule
