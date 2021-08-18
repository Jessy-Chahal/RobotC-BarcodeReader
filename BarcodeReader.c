#pragma config(StandardModel, "RVW Mammalbot")

task main()
{
	datalogClear();

	setMotorSpeed(leftMotor, 100);
	setMotorSpeed(rightMotor, 100);

	while (getUSDistance(S4) > 10) {
		datalogDataGroupStart();
		datalogAddValue(0, getColorReflected(colorSensor));
		datalogDataGroupEnd();
		wait1Msec(2);
	}
	setMotorSpeed(leftMotor, 0);
	setMotorSpeed(rightMotor, 0);
}
