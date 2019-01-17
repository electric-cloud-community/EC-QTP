my %runQTP = (
    label       => "QTP - Run QTP",
    procedure   => "runQTP",
    description => "Integrates QuickTest Pro Test Framework into Electric Commander",
    category    => "Test"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/QTP - Run QTP");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Run QTP");

@::createStepPickerSteps = (\%runQTP);
