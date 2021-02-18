% -------------------------------------------------------------------------
% Copyright (c) 2020
% Rémi Cogranne, UTT (Troyes University of Technology)
% All Rights Reserved.
% -------------------------------------------------------------------------
% This code is provided by the author under GNU GENERAL PUBLIC LICENSE GPLv3
% which, as explained on this webpage
% https://www.gnu.org/licenses/quick-guide-gplv3.html
% Allows modification, redistribution, provided that:
% * You share your code under the same license ;
% * That you give credits to the authors ;
% * The code is used only for Education or Research purposes.
% -------------------------------------------------------------------------

imgList = dir('/data/*.jpg');
for imgIdx = 1 : numel(imgList) ,
	fprintf('\n  ***** Processing image %s ***** \n' , imgList(imgIdx).name );
	Payload = 0.4;
	%read DCT coefficients from JPEG file
	coverStruct = jpeg_read( [ imgList(imgIdx).folder '/' imgList(imgIdx).name ] );
	%get stego DCT coefficients (and Deflection, pChanges and overall ChangeRate)
	tStart = tic;
	[stegoStruct, Deflection, pChange, ChangeRate ] = JMiPOD_fast(coverStruct, Payload);
	tEnd = toc(tStart);
	jpeg_write(stegoStruct , [ '/results/' imgList(imgIdx).name ])
	StegoDCT = coverStruct.coef_arrays{1};
	nbnzAC = ( sum( sum( StegoDCT ~= 0) ) - sum( sum( StegoDCT(1:8:end, 1:8:end) ~= 0 ) ) );
	pChange = pChange/2;
	HNats = -  2* pChange(:) .* log( pChange(:) ) -  (1- 2* pChange(:) )  .* log (1- 2* pChange(:) ) ;
	Hbits = -  2* pChange(:) .* log2( pChange(:) ) -  (1- 2* pChange(:) )  .* log2 (1- 2* pChange(:) ) ;
	fprintf("Payload * nbnzAC = %5.2f bits\nTernary entropy computed from pChanges is %5.2f bits = %5.2f Nats \n", Payload*nbnzAC, sum( Hbits ) , sum( HNats ) )
	fprintf("Data hiding carried out in %2.3f sec.\n", tEnd )
end