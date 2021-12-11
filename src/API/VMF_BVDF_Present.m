function VMF_BVDF_Present(corrupted_image)
    vmf_result = VectorMedianFilter(corrupted_image, 3);
    bvdf_result = BasicVectorDirectionalFilter(corrupted_image, 3);
    [diff_img, diff_img_count] = ColorImageDifference(vmf_result, bvdf_result);
    hybrid_result = DistanecDirectionalFilter(corrupted_image, 3);
    
    SameRatio = (size(corrupted_image, 1) .* size(corrupted_image, 2) - diff_img_count) ...
        / (size(corrupted_image, 1) .* size(corrupted_image, 2));
    sprintf("Sameness Ratio: %d", SameRatio);
    
    tiledlayout(2,3)
    nexttile
    imshow(corrupted_image)
    title("Corrupted Image")
    nexttile
    imshow(vmf_result)
    title("VMF")
    nexttile
    imshow(bvdf_result)
    title("BVDF")
    nexttile
    imshow(diff_img)
    title("Img Diff")
    nexttile
    imshow(hybrid_result)
    title("Hybrid")
    
    
end
