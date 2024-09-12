
mosaicA = zeros(30000, 16620 * 2, 3);

for i=1:3
    tile_32_path = sprintf('/data/eigil/work/lia_kq/Data/validation/optical/tile_3_2_mosaic_15m_band%d_v01.1.tif', i);
    tile_42_path = sprintf('/data/eigil/work/lia_kq/Data/validation/optical/tile_4_2_mosaic_15m_band%d_v01.1.tif', i);

    [eastA, eastR] = readgeoraster(tile_42_path);
    [westA, westR] = readgeoraster(tile_32_path);

    mosaicA(:, :, i) = [westA eastA];

    xlimits = [westR.XWorldLimits(1) eastR.XWorldLimits(2)];
    ylimits = westR.YWorldLimits;
    mosaicR = maprefcells(xlimits, ylimits, size(mosaicA));

    mosaicR.ColumnsStartFrom = eastR.ColumnsStartFrom;
    mosaicR.ProjectedCRS = eastR.ProjectedCRS;
end
