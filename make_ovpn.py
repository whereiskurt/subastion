import sys, os

ALLOW_FILE_OPTIONS = ["ca", "cert", "dh", "extra-certs", "key", "pkcs12", "secret", "crl-verify", "http-proxy-user-pass", "tls-auth", "tls-crypt"]

filepath = sys.argv[1]

output_file = os.path.basename(filepath). replace(".conf", ".ovpn")

inline_tuples_to_add = []

with open(output_file, 'w') as dst:
	with open(filepath) as src:
	    for l in src:
	        option = l.split()
	        if len(option) >= 2 and option[0] in ALLOW_FILE_OPTIONS and os.path.isfile(option[1]):
	        	inline_tuples_to_add.append((option[0], option[1]))
	        	continue

	        dst.write(l)

	dst.write("key-direction 1\n\n") # needed fot tls-auth

	for t in inline_tuples_to_add : 
		tag_begining = "<{}>\n".format(t[0])
		dst.write(tag_begining)
		with open(t[1]) as tag_cpntent_file:
			dst.writelines(tag_cpntent_file.readlines())
		tag_ending = "</{}>\n\n".format(t[0])
		dst.write(tag_ending)
