# Define the original content of config.cvs.example
original_content = """key,type,encoding,value
main,namespace,,
wifissid,data,string,myssid
wifipass,data,string,mypass
stratumurl,data,string,public-pool.io
stratumport,data,u16,21496
stratumuser,data,string,1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa.bitaxe
stratumpass,data,string,x
asicfrequency,data,u16,485
asicvoltage,data,u16,1200
asicmodel,data,string,BM1366
devicemodel,data,string,ultra
boardversion,data,string,204
flipscreen,data,u16,1
invertfanpol,data,u16,1
autofanspeed,data,u16,1
fanspeed,data,u16,100"""

# We'll create four different configurations by changing the boardversion
board_versions = ['201', '202', '203', '204']
config_files = {}

for version in board_versions:
    # Replace the boardversion value with each version
    modified_content = original_content.replace('boardversion,data,string,204', f'boardversion,data,string,{version}')
    # Store each modified content in a dict with the version as the key
    config_files[f'config_{version}.cvs'] = modified_content

for filename, content in config_files.items():
    # Open a new file in write mode with the filename
    with open(filename, 'w') as file:
        # Write the modified content to this new file
        file.write(content)
    print(f"Created {filename} with modified boardversion.")