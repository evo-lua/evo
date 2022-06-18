local testCases = {
	"./Tests/Extensions/table.spec.lua",
}

-- Crappy makeshift test runner... for now it will do
local numTestsComplete = 0
local numFailedTests = 0

local string_rep = string.rep
local print = print

local bold = transform.bold
local gray = transform.gray

local indent = 0
local function indentText(text, ...)
	print(string_rep("  ", indent) .. text, ...)
end

local function describe(description, codeUnderTest)
	indentText(bold(description))
	indent = indent + 1

	codeUnderTest()
	numTestsComplete = numTestsComplete + 1

	indent = indent - 1
end

local iconFail = transform.red("✗")
local iconSuccess = transform.green("✓")

local function it(label, codeUnderTest)
	indent = indent + 1

	local success = pcall(codeUnderTest)
	local icon = success and iconSuccess or iconFail
	indentText(icon .. " " .. gray(label))

	if success then
		numTestsComplete = numTestsComplete + 1
	else
		numFailedTests = numFailedTests + 1
	end

	indent = indent - 1
end

_G.describe = describe
_G.it = it

local uv = require("uv")

local timeStart = uv.hrtime()

for _, testFile in ipairs(testCases) do
	import(testFile)
end

local timeEnd = uv.hrtime()
local durationInMilliseconds = (timeEnd - timeStart) / 10E6 -- ns (hrtime) to ms

print()

if numFailedTests > 1 then
	printf(transform.brightRedBackground("✗ %s tests FAILED (%s ms)"), numFailedTests, durationInMilliseconds)
elseif numFailedTests == 1 then
	printf(transform.brightRedBackground("✗ %s test FAILED (%s ms)"), numFailedTests, durationInMilliseconds)
elseif numTestsComplete > 1 then
	printf(transform.green("✓ %s tests complete (%s ms)"), numTestsComplete, durationInMilliseconds)
else
	printf(transform.green("✓ %s test complete (%s ms)"), numTestsComplete, durationInMilliseconds)
end

os.exit(numFailedTests)