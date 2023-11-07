--!strict
local ORIGIN: CFrame = CFrame.new(0, 16, 0); -- nav volume is a square of WIDTH centred to ORIGIN
local WIDTH: number = 32;
local MIN_SIZE: number = 1; -- minimum cell size, required for recursion to end

--local TERRAIN: Terrain = workspace.Terrain;

local FIND_PARAMS: OverlapParams = OverlapParams.new();
FIND_PARAMS.RespectCanCollide = true;
FIND_PARAMS.MaxParts = 1;

type Volume = {
    Centre: CFrame,
    Width: number
}

--[[local function containsTerrain(volume: Volume): boolean
    local region: Region3 = Region3.new(
        (4 * TERRAIN:WorldToCellPreferSolid(volume.Centre.Position)) - Vector3.new(volume.Width / 2, volume.Width / 2, volume.Width / 2),
        (4 * TERRAIN:WorldToCellPreferSolid(volume.Centre.Position)) + Vector3.new(volume.Width / 2, volume.Width / 2, volume.Width / 2)
    );
    print(tostring(region.CFrame.Position) .. ":" .. tostring(volume.Centre.Position));
    print(tostring(region.Size) .. ":" .. tostring(Vector3.new(volume.Width, volume.Width, volume.Width)));

    local materials = TERRAIN:ReadVoxels(region, 4);
    for _, i in ipairs(materials) do
        for _, j in ipairs(i) do
            for _, k in ipairs(j) do
                if k ~= Enum.Material.Air then
                    return true;
                end
            end
        end
    end

    return false;
end--]]

--local hit: { Volume } = {}
local function divide(centre: CFrame, width: number): (Volume | { Volume })? -- divide region into non-intersecting areas, returns table of Volumes
    local collision: { BasePart } = workspace:GetPartBoundsInBox(centre, Vector3.new(width - 0.1, width - 0.1, width - 0.1), FIND_PARAMS);
    if #collision == 0 --[[and not containsTerrain{Centre = centre, Width = width}--]] then
        return {Centre = centre, Width = width};
    elseif width > MIN_SIZE then -- split volume into 8 segments and check them individually
        local offset: number = width / 4;
        local results: { Volume } = {};
        for i = -1, 1, 2 do
            for j = -1, 1, 2 do
                for k = -1, 1, 2 do
                    local newCollision: (Volume | { Volume })? = divide(
                        CFrame.new(
                            centre.X + i * offset,
                            centre.Y + j * offset,
                            centre.Z + k * offset
                        ),
                        offset * 2
                    );
                    if newCollision then
                        if newCollision["Centre"] then
                            table.insert(results, newCollision);
                        elseif #newCollision then
                            table.move(newCollision, 1, #newCollision, #results + 1, results);
                        end
                    end
                end
            end
        end
        return results;
    end

    --table.insert(hit, {Centre = centre, Width = width});
    return; -- if MIN_SIZE and collision, volume is invalid and cannot be divided
end

local navVolume: { Volume } = divide(ORIGIN, WIDTH) :: { Volume };
for _, v in ipairs(navVolume) do
    local part: Part = Instance.new("Part");
    part.CFrame = v.Centre;
    --part.Size = Vector3.new(v.Width - 0.1, v.Width - 0.1, v.Width - 0.1);
    part.Size = Vector3.new(MIN_SIZE, MIN_SIZE, MIN_SIZE);
    part.BrickColor = BrickColor.White();
    part.Material = Enum.Material.SmoothPlastic;
    part.Transparency = 0.9;
    part.CastShadow = false;
    part.CanCollide = false;
    part.CanQuery = false;
    part.Anchored = true;
    part.Parent = workspace.navVolume;
end

--[[for _, v in ipairs(hit) do
    local part: Part = Instance.new("Part");
    part.CFrame = v.Centre;
    part.Size = Vector3.new(v.Width - 0.1, v.Width - 0.1, v.Width - 0.1);
    part.BrickColor = BrickColor.Red();
    part.Material = Enum.Material.SmoothPlastic;
    part.Transparency = 0.5;
    part.CastShadow = false;
    part.CanCollide = false;
    part.CanQuery = false;
    part.Anchored = true;
    part.Parent = workspace.navVolume;
end--]]
