# createTemplate.sh: create a launch template to use with other scripts to create nodes. Please verift ImageId, InstanceType, KeyName below!
aws ec2 create-launch-template --launch-template-name carlos-i3-template --query 'LaunchTemplate.LaunchTemplateId' --launch-template-data  \
    '{ 
                "EbsOptimized": true,
                "IamInstanceProfile": {
                    "Arn": "arn:aws:iam::139258803600:instance-profile/Carlos_1532516077576_1105"
                },
                "BlockDeviceMappings": [
                    {
                        "DeviceName": "/dev/sdb",
                        "VirtualName": "",
                        "Ebs": {
                            "DeleteOnTermination": true,
                            "VolumeSize": 20,
                            "VolumeType": "gp2"
                        }
                    }
                ],
                "NetworkInterfaces": [
                    {
                        "AssociatePublicIpAddress": true,
                        "DeviceIndex": 0,
                        "Groups": [
                            "sg-171f705d"
                        ],
                        "SubnetId": "subnet-5ad7a810"
                    }
                ],
                "ImageId": "ami-ab6e3bd4",
                "InstanceType": "i3.4xlarge",
                "KeyName": "Carlos",
                "UserData": "IyEvYmluL2Jhc2ggDQpzZXQgLXggDQpleGVjIDE+ID4odGVlIC1hIC9yb290L3J1bl9vbmNlLmxvZykgMj4mMSANCiMgYWRkZWQgdG8gYXNzaXN0IHZlcnRpY2EgaW5zdGFsbCANCiMgc2V0IHRoZSByb290IHZvbHVtZSBzY2hlZHVsZXIgYW5kIHJlYWQgYWhlYWQgb3B0aW9ucyBjb3JyZWN0bHkgDQplY2hvIG5vb3AgPiAgL3N5cy9ibG9jay94dmRhL3F1ZXVlL3NjaGVkdWxlciANCi9zYmluL2Jsb2NrZGV2IC0tc2V0cmEgMjA0OCAvZGV2L3h2ZGExIA0Kc3lzdGVtY3RsIHN0YXJ0IGNocm9ueWQgIA0Kc3lzdGVtY3RsIHN0YXR1cyBjaHJvbnlkDQojIENyZWF0ZSBuZXcgZGJhZG1pbiB1c2VyDQpbICdkYmFkbWluJyAhPSBkYmFkbWluIF0gJiYgdXNlcmFkZCBkYmFkbWluIC1nIHZlcnRpY2FkYmENCiMgcmVtb3ZlIG9sZCBkZXZpY2UgbWFwcGluZ3MNCnVtb3VudCAvbW50IA0Kc2VkIC1pICIvdmVydGljYVwvZGF0YS9kOy9kZXZcL3h2ZC9kIiAvZXRjL2ZzdGFiIA0KIyBTZXR1cCB0aGUgZGlzayByYWlkDQplY2hvIFllcyB8IHNoIC9vcHQvdmVydGljYS9zYmluL2NvbmZpZ3VyZV9hd3Nfc29mdHdhcmVfcmFpZC5zaCAtdSBkYmFkbWluIC10IEVQSCAtbSAvdmVydGljYS9kYXRhIC1kIC9kZXYvbnZtZTBuMSwvZGV2L252bWUxbjEsL2Rldi9udm1lMm4xLC9kZXYvbnZtZTNuMSwvZGV2L252bWU0bjEsL2Rldi9udm1lNW4xLC9kZXYvbnZtZTZuMSwvZGV2L252bWU3bjENCmlmIFsgRU9OID09ICdFT04nIF07IHRoZW4NCiAgc3VkbyBsbiAtcyAvdmVydGljYS9kYXRhIC9zY3JhdGNoX2INCmZpIA0KIyBjb25uZWN0IGFsbCB0aGUgaW5zdGFuY2UNCiNzdWRvIGJhc2ggLWMgIm5jIC1sIDU0MzMgPj4gL2hvbWUvZGJhZG1pbi8uc3NoL2F1dGhvcml6ZWRfa2V5cyINClsgJ2RiYWRtaW4nICE9IGRiYWRtaW4gXSAmJiBzdWRvIGNwIC1yIC9ob21lL2RiYWRtaW4vLnNzaCAvaG9tZS9kYmFkbWluLy5zc2g7IHN1ZG8gY2hvd24gLVIgZGJhZG1pbjp2ZXJ0aWNhZGJhIC9ob21lL2RiYWRtaW4vLnNzaA0KZWNobyAnc3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFCQVFDNEpVcHBkeUE1bk4yRWZ5SVUwWkg0d0NwYXVpOFl0MUFTZGJyVnMyUG85d1ROTmlYK2V5cDVkRzRyYm9Nb2cyTmQ0ZFMvZlU3VjZGam5Dc0xydzQyZ3hOcWxmbWNNRXZJcnd6TkhPcjZFZ21VWjNldHNRT05VRGJKZDNEcm1LamdkMmtJN3lTeDd0bkpaNXVDNE5IUHF4V2hvUDVTLzBEZk5QZmU1MnNkbkI0OVVtWTVwTDdUbkZmcHRtbHRyM1RjVUs5WDVaQUtMRGQ0V0dkL1R1UzdQVVNCQWJXS0xmckdzQkNpS2FtT2I1TVhudU5sMW9TTXByU0FVSE5BUTI3NE9BbFU3VTFXNklVRFBZN0pOMURUbTBHRzhtQmNEREdMTGR2SnlVeGF3Z1hWSS9aV2pVVXFrZVpWaDd3RXhjOS9kbnFoMy91Y3JRYXFCMVRqaDRQaDEnID4+ICAvaG9tZS9kYmFkbWluLy5zc2gvYXV0aG9yaXplZF9rZXlzDQpzdWRvIGVjaG8gJ2RiYWRtaW4gICAgICBBTEw9KEFMTCkgICAgICBOT1BBU1NXRDpBTEwnID4gL2V0Yy9zdWRvZXJzLmQvdmVydGljYSAgDQojIEFsbCBkb25lDQo="
            }' > .template_id


